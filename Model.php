<?php

include_once __DIR__ . '/vendor/autoload.php';

class Model
{
  public function __construct($address = '', $parser = null, $lexer = null, $visitors = null)
  {
    $this->connectTo($address);
    $this->initialize();
    $this->setParser($parser, $lexer);
    $this->addVisitor(new PHPParser_NodeVisitor_NameResolver());
  }

  public function connectTo($address = '')
  {
    try {
      $this->_redis = new Predis\Client();
      $this->_redis->connect();
      echo "Successfully connected to Redis server\n";
    } catch (Exception $e) {
      exit("Couldn't connected to Redis server\n{$e->getMessage()}\n");
    }
  }

  public function initialize()
  {
    $this->clear();
    $this->_redis->sadd('namespaces', 'N:\\');
    $this->_redis->sadd('classes', 'C:\\stdClass');
    $this->_redis->sadd('scalar_types', array('boolean', 'int', 'double', 'string', 'array'));
  }

  public function addVisitor($visitor)
  {
    if ($visitor instanceof PHPParser_NodeVisitor)
      $this->setTraverser()->addVisitor($visitor);
    else
      echo "You're trying to add a visitor that doesn't have the proper interface\n";
  }

  public function setParser(PHPParser_Parser $parser = null, PHPParser_Lexer $lexer = null)
  {
    return $this->parser = $parser ? $parser : new PHPParser_Parser($this->setLexer($lexer));
  }

  public function setLexer(PHPParser_Lexer $lexer = null)
  {
    return $this->lexer = $lexer ? $lexer : new PHPParser_Lexer;
  }

  public function setTraverser(PHPParser_NodeTraverser $traverser = null)
  {
    return $this->traverser = $traverser ? $traverser : new PHPParser_NodeTraverser;
  }

  public function clear()
  {
    return $this->_redis->flushall();
  }

  public function get()
  {
    return $this->_redis;
  }

  public function build($path, $recursive = true)
  {
    $files = $this->getFiles($path, $recursive);
    $this->node_dumper = new PHPParser_NodeDumper;
    foreach ($files as $file)
      $this->buildForFile($file);
  }

  public function buildForFile($file)
  {
    try {
      echo "{$file}\n";
      $source_code = file_get_contents($file);
      $statements = $this->traverser->traverse($this->parser->parse($source_code));
      $this->populate($statements);
      // $redis->set("{$file}", serialize($statements));
      $dump = $this->node_dumper->dump($statements);
      file_put_contents('./test_codebase_asts/'.$this->replaceExtension($file,'ast'), $dump);
      die();
    } catch (PHPParser_Error $e) {
      echo "Parse Error: {$e->getMessage()}";
    }
  }

  private function populate($statements)
  {
    if (!$statements) return;
    foreach ($statements as $key => $node_object)
      $this->insertNode($node_object);
  }

  private function getFiles($root_directory, $recursive)
  {
    if (!file_exists($root_directory) && !is_dir($root_directory)) {
      echo "Directory \"{$root_directory}\" not found\n";
      return array();
    }
    $files = array();
    $stack[] = $root_directory;
    while ($stack) {
      $current_directory = array_pop($stack);
      $directory_content = scandir($current_directory);
      foreach ($directory_content as $content) {
        if ($content === '.' || $content === '..') continue;
        $current_element = "{$current_directory}/{$content}";
        $extension = pathinfo($current_element, PATHINFO_EXTENSION);
        if (is_file($current_element) && is_readable($current_element) && $extension === 'php')
          $files[] = $current_element;
        elseif (is_dir($current_element) && $recursive)
          $stack[] = $current_element;
      }
    }
    return $files;
  }

  private function replaceExtension($file_path, $new_extension)
  {
    $path_information = pathinfo($file_path);
    return "{$path_information['filename']}.{$new_extension}";
  }

  private function insertNode(PHPParser_Node $node_object)
  {
    switch (get_class($node_object)) {
      case 'PHPParser_Node_Stmt_Namespace':
        $this->insertNamespace($node_object);
        break;
      case 'PHPParser_Node_Stmt_Class':
        $this->insertClass($node_object);
        break;
      case 'PHPParser_Node_Stmt_Function':
        $this->insertFunction($node_object);
        break;
      case 'PHPParser_Node_Stmt_ClassMethod':
        $this->insertClassMethod($node_object);
        break;
      case 'PHPParser_Node_Expr_Assign':
        $this->insertAssignement($node_object);
        break;
    }
  }

  private function insertNamespace(PHPParser_Node_Stmt_Namespace $node_object)
  {
    $namespace_key = 'N:\\'.implode('\\', $node_object->name->parts);
    $this->_redis->sadd('namespaces', $namespace_key);
    $this->insertNamespaceHierarchy($node_object->name->parts);
    $this->populateIteratively($node_object->stmts, $namespace_key);
  }

  private function insertNamespaceHierarchy(array $namespace_name_parts)
  {
    $parent_namespace = '\\';
    $current_namespace = '';
    foreach ($namespace_name_parts as $key => $sub_namespace) {
      $current_namespace .= "\\{$sub_namespace}";
      $this->_redis->sadd('namespaces', "N:{$current_namespace}");
      $this->_redis->sadd("N:{$current_namespace}:]N", "N:{$parent_namespace}");
      $this->_redis->sadd("N:{$parent_namespace}:[N", "N:{$current_namespace}");
      $parent_namespace = $current_namespace;
    }
  }

  private function insertClass(PHPParser_Node_Stmt_Class $node_object)
  {
    $class_key = 'C:\\'.implode('\\', $node_object->namespacedName->parts);
    $this->_redis->sadd('classes', $class_key);
    $this->insertClassHierarchy($node_object, $class_key);
    $this->insertContainmentRelationship($class_key, 'C', 'N');
    $this->populateIteratively($node_object->stmts, $class_key);
  }

  private function insertClassHierarchy(PHPParser_Node_Stmt_Class $node_object, $current_class_key)
  {
    if (!$superclass = $node_object->extends) return;
    $superclass_key = 'C:\\'.implode('\\', $superclass->parts);
    $this->_redis->sadd('classes', $superclass_key);
    $this->_redis->sadd("{$current_class_key}:>", $superclass_key);
    $this->_redis->sadd("{$superclass_key}:<", $current_class_key);
  }

  private function insertFunction(PHPParser_Node_Stmt_Function $node_object)
  {
    $function_key = 'F:\\'.implode('\\', $node_object->namespacedName->parts);
    $this->_redis->sadd('functions', $function_key);
    $this->insertContainmentRelationship($function_key, 'F', 'N');
    $this->populateIteratively($node_object->stmts, $function_key);
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {
    $class = substr($this->_redis->lrange('scope', 0, 0)[0], 2);
    $method_key = "M:{$class}\\{$node_object->name}";
    $this->insertContainmentRelationship($method_key, 'M', 'C', $class);
    $this->populateIteratively($node_object->stmts, $method_key);
  }

  private function insertContainmentRelationship($contained_element, $contained_type, $container_type, $container = null)
  {
    if ($container) {

      $this->_redis->sadd("{$container_type}:{$container}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container);

    } elseif ($container = $this->_redis->lrange('scope', 0, 0) && isset($container[0])) {

      $this->_redis->sadd("{$container[0]}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container[0]);

    }
  }

  private function populateIteratively($statements, $key)
  {
    if (!$statements) return;
    $this->_redis->lpush('scope', $key);
    $this->populate($statements);
    $this->_redis->lpop('scope');
  }

  private function insertAssignement(PHPParser_Node_Expr_Assign $node_object)
  {
    var_dump($this->getLeftValue($node_object->var));
    // if ($node_object->var instanceof PHPParser_Node_Expr_Variable) {
    //   if ($node_object->var->name instanceof PHPParser_Node_Expr_Variable)
    //     var_dump($node_object->var->name->name);
    //   else
    //     var_dump($node_object->var->name);
    // } elseif ($node_object->var instanceof PHPParser_Node_Expr_ArrayDimFetch)
    //   var_dump($node_object->var-name);
    //   $this->insertLeftValue($node_object->var->name);
    // elseif ($node_object->var->name instanceof String)
    //   $this->insert("variable {$node_object->var->name}");
  }

  private function getLeftValue($left_value)
  {
    if ($left_value instanceof PHPParser_Node_Expr_Variable)
      return $this->getLeftValue($left_value->name);
    if ($left_value instanceof PHPParser_Node_Expr_ArrayDimFetch)
      return $this->getLeftValue($left_value->var)."[{$left_value->dim->value}]";
    $scope = $this->_redis->lrange('scope', 0, 0);
    $scope[0][0] = 'V';
    return "{$scope[0]}\\{$left_value}";
  }

  // private function insertVariable($node, $right_expression)
  // {
  //   if ($node->name instanceof PHPParser_Node_Expr_Variable)
  //     var_dump($node);
  //   else {
  //     $scope = $this->_redis->lrange('scope', 0, 0);
  //     var_dump($scope);
  //   }
  // }

  // private function getRightValue($node)
  // {
  //   if ($node instanceof PHPParser_Node_Expr_New)
  //     echo '1';
  //   else
  //     echo '2';
  // }

}

?>
