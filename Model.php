<?php

include_once __DIR__ . '/vendor/autoload.php';

class Model
{
  public function __construct($server_path = 'vendor/redis-2.6.16/src/',
                              $server_executable = 'redis-server',
                              $address = '', $parser = null, $lexer = null,
                              $traverser = null, $visitors = array())
  {
    $this->startRedisServer($server_path, $server_executable);
    $this->connectTo($address);
    $this->initialize();
    $this->setParser($parser, $lexer);
    $this->setTraverser($traverser);
    $this->setVisitors(array(new PHPParser_NodeVisitor_NameResolver()));
  }

  private function startRedisServer($server_path, $server_executable)
  {
    exec("pgrep {$server_executable}", $output, $return);
    if ($return == 0) {
      echo "{$server_path}{$server_executable} is already running\n";
    } else {
      shell_exec("nohup {$server_path}{$server_executable} > /dev/null & echo $!");
      echo "{$server_path}{$server_executable} started\n";
    }
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

    // strutture di utilità
    $this->_redis->sadd('non_namespace_statements', array('Stmt_Namespace', 'Stmt_Class', 'Stmt_Function'));
    // strutture temporanee
    $this->_redis->lpush('scope', 'N:\\');
    $this->_redis->sadd('scoped_global_variables', '');
  }

  public function setVisitors(array $visitors)
  {
    foreach ($visitors as $key => $visitor) {
      $interfaces = class_implements($visitor);
      if (isset($interfaces['PHPParser_NodeVisitor'])) {
        $this->traverser->addVisitor($visitor);
      } else {
        echo "You're trying to add a visitor that doesn't have the proper interface\n";
      }
    }
  }

  public function setParser(PHPParser_Parser $parser = null, PHPParser_Lexer $lexer = null)
  {
    return $this->parser = $parser ? $parser : new PHPParser_Parser($this->setLexer($lexer));
  }

  public function setLexer(PHPParser_Lexer $lexer = null)
  {
    return $this->lexer = $lexer ? $lexer : new PHPParser_Lexer_Emulative;
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
        if (is_file($current_element) && is_readable($current_element) && $extension === 'php') {
          $files[] = $current_element;
        } elseif (is_dir($current_element) && $recursive) {
          $stack[] = $current_element;
        }
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
    $scope = $this->_redis->lrange('scope', 0, 0)[0];
    $node_type = $node_object->getType();
    if ($scope === "N:\\" && !$this->_redis->sismember('non_namespace_statements', $node_type)) {
      $this->_redis->lpush($scope, serialize($node_object));
    }
    if ($node_type === 'Stmt_Namespace') {
      $this->insertNamespace($node_object);
    } elseif ($node_type === 'Stmt_Class') {
      $this->insertClass($node_object);
    } elseif ($node_type === 'Stmt_Function') {
      $this->insertFunction($node_object);
    } elseif ($node_type === 'Stmt_ClassMethod') {
      $this->insertClassMethod($node_object);
    } elseif ($node_type === 'Expr_Assign') {
      $this->insertAssignment($node_object);
    } elseif ($node_type === 'Stmt_Property') {
      $this->insertClassProperty($node_object);
    } elseif ($node_type === 'Stmt_Global') {
      $this->insertScopedGlobalVariable($node_object);
    }
  }

  private function insertRawStatements(array $raw_statements, $statement_key)
  {
    foreach ($raw_statements as $key => $raw_statement) {
      $this->_redis->lpush($statement_key, serialize($raw_statement));
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
      $current_namespace_key = "N:{$current_namespace}";
      $this->_redis->sadd('namespaces', $current_namespace_key);
      $this->insertContainmentRelationship($current_namespace_key, 'N', 'N', $parent_namespace);
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
    $this->insertParameters($node_object);
    $function_key = 'F:\\'.implode('\\', $node_object->namespacedName->parts);
    $this->_redis->sadd('functions', $function_key);
    $this->insertContainmentRelationship($function_key, 'F', 'N');
    $this->insertRawStatements($node_object->stmts, $function_key);
    $this->populateIteratively($node_object->stmts, $function_key);
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {
    $this->insertParameters($node_object);
    $class = substr($this->_redis->lrange('scope', 0, 0)[0], 2);
    $method_key = "M:{$class}\\{$node_object->name}";
    $this->_redis->sadd('methods', $method_key);
    $this->insertContainmentRelationship($method_key, 'M', 'C', $class);
    $this->insertRawStatements($node_object->stmts, $method_key);
    $this->populateIteratively($node_object->stmts, $method_key);
  }

  private function insertParameters($node_object)
  {
    if (!$parameters = $node_object->params) return;
    foreach ($parameters as $key => $parameter) {
      // l'inserimento dei parametri può essere inteso come l'inserimento di variabili locali
      // aventi già un tipo associato che è quello del valore di default o quello indicato dall'hint
      //var_dump($parameter->getLine())
    }
  }

  // insertAssignement deve discriminare le variabili locali a funzioni e metodi,
  // globali e le proprietà delle classi
  private function insertAssignment($node_object)
  {
    if ($node_object->var instanceof PHPParser_Node_Expr_PropertyFetch && $node_object->var->var->name === 'this') {
      // assegnamento di una proprietà (i.e. attributo di classe)
      //var_dump($node_object->var->getLine())
    } elseif ($node_object->var->var instanceof PHPParser_Node_Expr_Variable && $node_object->var->var->name === 'GLOBALS') {
      // assegnamento di una variabile globale nella forma $GLOBALS['a'] = espressione
      // il nome della variabile si ottiene per mezzo di $node_object->var->dim->value
      //var_dump($node_object->var->getLine())
    } elseif ($node_object->var->var instanceof PHPParser_Node_Expr_ArrayDimFetch && $node_object->var->var->var->name === 'GLOBALS') {
      // assegnamento di una variabile globale nella forma $GLOBALS['a']['b'] = espressione;
      // il nome della variabile si ottiene per mezzo di $this->getGlobalsVariableName($node_object->var);
      //var_dump($node_object->var->getLine())
    } else {
      $container = $this->_redis->lrange('scope', 0, 0)[0];
      $variable_name = $this->getVariableName($node_object);
      if ($container === 'N:\\') {
        // se sono nello scope generale significa che ho un assegnamento di una variabile globale
        // il nome della variabile è $variable_name;
        //var_dump($node_object->var->getLine())
      } else {
        // se NON sono nello scope generale vado a verificare che la variabile non sia una di quelle definite come globali
        $global_variable_key_in_scope = $container.'\\'.$variable_name;
        if ($this->_redis->sismember('scoped_global_variables', $global_variable_key_in_scope)) {
          // assegnamento di una variabile globale
          // il nome della variabile è $variable_name;
          //var_dump($node_object->var->getLine())
        } else {
          // assegnamento di una variabile locale
          // il nome della variabile è $variable_name;
          //var_dump($node_object->var->getLine())
        }
      }
    }
    // $variable = $this->getVariableName($node_object->var);
    // $scope = $this->_redis->lrange('scope', 0, 0);
    // $container = substr($scope[0], 2);
    // $variable_key = "V:{$container}\\{$variable}";
    // // check per variabile già definita
    // var_dump($this->_redis->sismember('variables', $variable_key));
    // $this->_redis->sadd('variables', $variable_key);
    // $this->insertContainmentRelationship($variable_key, 'V', $scope[0][0], $container);
  }

  private function getGlobalsVariableName($variable)
  {
    if ($variable->var instanceof PHPParser_Node_Expr_ArrayDimFetch) {
      return $this->getGlobalsVariableName($variable->var)."[{$variable->dim->value}]";
    } else {
      return $variable->dim->value;
    }
  }

  private function getVariableName($variable)
  {
    if ($variable instanceof PHPParser_Node_Expr_Variable)
      return $this->getVariableName($variable->name);
    if ($variable instanceof PHPParser_Node_Expr_ArrayDimFetch)
      return $this->getVariableName($variable->var)."[{$variable->dim->value}]";
    if ($variable instanceof PHPParser_Node_Expr_PropertyFetch)
      return $this->getVariableName($variable->var)."->{$variable->name}";
    if ($variable instanceof PHPParser_Node_Expr_Assign)
      return $this->getVariableName($variable->var);
    if (is_string($variable))
      return $variable;
    return 'NO_NAME_FOUND';
  }


  private function insertScopedGlobalVariable($node_object)
  {
    foreach ($node_object->vars as $key => $variable) {
      $container = $this->_redis->lrange('scope', 0, 0)[0];
      // non modifico la prima lettera della chiave della variabile globale visto che il dato che
      // memorizzo mi serve solo temporaneamente per il controllo in insertAssignement
      $global_variable_key = $container.'\\'.$variable->name;
      $this->_redis->sadd('scoped_global_variables', $global_variable_key);
    }
  }

  // le proprietà delle classi potrebbero essere trattate (i.e. rappresentate) nello stesso modo degli assegnamenti...
  private function insertClassProperty($node_object)
  {
    //var_dump($node_object->getLine())
  }

  // la procedura di inserimento prevede di specificare o meno il container per
  // motivi di preformance. Ho voluto ottimizzare ed evitare di andare a prendere due
  // volte lo scope visto che per i namespace, i metodi e gli assegnamenti c'è sempre bisogno dello
  // scope prima dell'inserimento delle relazioni di contenimento
  private function insertContainmentRelationship($contained_element, $contained_type, $container_type, $container = null)
  {
    if ($container) {

      $this->_redis->sadd("{$container_type}:{$container}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", "{$container_type}:{$container}");

    } else {

      $container = $this->_redis->lrange('scope', 0, 0);
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

}

?>
