<?php

include_once __DIR__ . '/vendor/autoload.php';

class Model
{
  public function __construct($server_path = 'vendor/redis-2.8.5/src/',
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
      $this->_redis->rpush($scope, serialize($node_object));
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
      $this->insertInScopeGlobalVariable($node_object);
    }
  }

  private function insertRawStatements($key, array $raw_statements)
  {
    foreach ($raw_statements as $i => $raw_statement) {
      $this->_redis->rpush($key, serialize($raw_statement));
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
    $namespaced_name = '\\'.implode('\\', $node_object->namespacedName->parts);
    $function_key = 'F:'.$namespaced_name;
    $this->_redis->sadd('functions', $function_key);
    $this->insertParameters($node_object, 'F', $namespaced_name);
    $this->insertContainmentRelationship($function_key, 'F', 'N');
    $this->insertRawStatements($function_key, $node_object->stmts);
    $this->populateIteratively($node_object->stmts, $function_key);
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {
    $class = substr($this->_redis->lrange('scope', 0, 0)[0], 2);
    $container_key = $class.'\\'.$node_object->name;
    $method_key = 'M:'.$container_key;
    $this->_redis->sadd('methods', $method_key);
    $this->insertParameters($node_object, 'M', $container_key);
    $this->insertContainmentRelationship($method_key, 'M', 'C', $class);
    $this->insertRawStatements($method_key, $node_object->stmts);
    $this->populateIteratively($node_object->stmts, $method_key);
  }

  // attenzione in insertParameters inserisco anche i parametri raw nella funzione o metodo da
  // cui lo chiamo!!! inserendo qui evito di dover mergiare l'array dei
  // parametri con quello degli statements ma rendo la chiamata di insertParameters necessaria
  // prima di insertRawStatements!!!
  private function insertParameters($node_object, $container_type, $container_key)
  {
    if (!$parameters = $node_object->params) return;
    foreach ($parameters as $key => $parameter) {
      // l'inserimento dei parametri può essere inteso come l'inserimento di variabili locali
      // aventi già un tipo associato che è quello del valore di default o quello indicato dall'hint
      //var_dump($parameter->getLine())
      $parameter_key = 'L:'.$container_key.'\\'.$parameter->name;
      $this->_redis->lpush($parameter_key, null);
      $this->_redis->sadd("{$container_type}:{$container_key}:[L", $parameter_key);
      $this->_redis->rpush($container_type.':'.$container_key, serialize($parameter));
    }
  }

  // ritorna il nome della variabile globale oppure false se non ho una variabile globale
  private function getGlobalVariableName($variable_name)
  {
    $global_variables = array('GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER', 'FILES', '_SESSION', '_ENV', '_COOKIE');
    foreach ($global_variables as $key => $global_variable) {
      if (strpos($variable_name, $global_variable) === 0) {
        preg_match("/{$global_variable}\['(\\w)'\]/", $variable_name, $matches);
        return $matches[1].str_replace($matches[0], '', $variable_name);
      }
    }
    return false;
  }

  // insertAssignement deve discriminare le variabili locali a funzioni e metodi,
  // globali e le proprietà delle classi
  // ...questo metodo mi sa tanto di regola
  private function insertAssignment($node_object)
  {
    $variable_name = $this->getVariableName($node_object->var);
    $global_variable = $this->getGlobalVariableName($variable_name);
    // caso di assegnamento all'array GLOBALS o ad una delle varibili globali di PHP
    if ($global_variable !== false) {

      $this->_redis->sadd('global_variables', 'G:'.$global_variable);

    // caso di assegnamento a proprietà della classe sotto analisi
    } elseif (strpos($variable_name, 'this') === 0) {

      $variable_name = str_replace('this->', '', $variable_name);
      $class = $this->_redis->lrange('scope', 0, 1)[1];
      $this->_redis->sadd('local_variables', $class.':[P');
      $this->_redis->sadd($class.':[P', substr_replace($class, 'P:', 0, 2).'\\'.$variable_name);

    // caso di assegnamento a proprietà STATICHE della classe sotto analisi
    } elseif (strpos($variable_name, 'self') === 0) {

      $variable_name = str_replace('self::', '', $variable_name);
      $class = $this->_redis->lrange('scope', 0, 1)[1];
      $this->_redis->sadd('local_variables', $class.':[P');
      $this->_redis->sadd($class.':[P', substr_replace($class, 'P:', 0, 2).'\\'.$variable_name);

    // caso di assegnamento a proprietà STATICHE di classi diverse da quella sotto analisi
    // qui ho un problema...se non ho ancora analizzato la classe a cui sto facendo riferimento???
    } elseif (strpos($variable_name, '::') !== false) {

      $class_name = strstr($variable_name, '::', true);
      $variable_name = str_replace($class_name.'::', '', $variable_name);
      $this->_redis->sadd('local_variables', 'C:\\'.$class_name.':[P');
      $this->_redis->sadd('C:\\'.$class_name.':[P', 'P:\\'.$class_name.'\\'.$variable_name);

    // caso di assegnamento a variabili locali al metodo, funzione, o namespace
    // solo qui devo verificare che la variabile sia effettivamente locale e non sia invece
    // una di quelle definite come globali!!! (i.e. globals $a, $b, $c)
    } else {

      $container = $this->_redis->lrange('scope', 0, 0)[0];
      $this->_redis->sadd('local_variables', $container.':[L');
      $this->_redis->sadd($container.':[L', substr_replace($container, 'L:', 0, 2).'\\'.$variable_name);

    }

  }

  private function getVariableName($variable)
  {
    if (is_string($variable)) {
      return $variable;
    }
    if ($variable->getType() === 'Expr_Variable') {
      return $this->getVariableName($variable->name);
    }
    if ($variable->getType() === 'Expr_ArrayDimFetch'){
      return $this->getVariableName($variable->var)."['{$variable->dim->value}']";
    }
    if ($variable->getType() === 'Expr_PropertyFetch') {
      return $this->getVariableName($variable->var)."->{$variable->name}";
    }
    if ($variable->getType() === 'Expr_Assign') {
      return $this->getVariableName($variable->var);
    }
    if ($variable->getType() === 'Expr_StaticPropertyFetch') {
      return $variable->class."::{$variable->name}";
    }
    return 'NO_NAME_FOUND';
  }


  private function insertInScopeGlobalVariable($node_object)
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
