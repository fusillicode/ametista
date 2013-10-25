<?php

class Model
{
  public function __construct($address = '')
  {
    $this->connectTo($address);
    $this->initializeModel();
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

  public function initializeModel()
  {
    $this->clear();
    $this->_redis->sadd('namespaces', 'N:\\');
    $this->_redis->sadd('classes', 'C:\\stdClass');
    $this->_redis->sadd('scalar_types', array('boolean', 'int', 'double', 'string', 'array'));
  }

  public function clear() { return $this->_redis->flushall(); }

  public function get() { return $this->_redis; }

  public function build() {}

  public function populate($statements)
  {
    if (!$statements) return;
    foreach ($statements as $key => $node_object)
      $this->insertNode($node_object);
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
      // case 'PHPParser_Node_Stmt_Function':
      //   $this->insertFunction($node_object);
      //   break;
      // case 'PHPParser_Node_Stmt_ClassMethod':
      //   $this->insertClassMethod($node_object);
      //   break;
      // case 'PHPParser_Node_Expr_Assign':
      //   $this->insertAssignement($node_object);
      //   break;
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

  // private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  // {
  //   $class = substr($this->_redis->lrange('scope', 0, 0)[0], 2);
  //   $method_key = $this->insertKey($node_object->name, "M:{$class}", 'methods');
  //   $this->insertContainmentRelationship($method_key, 'M', 'C', $class);
  //   $this->populateIteratively($node_object->stmts, $method_key);
  // }

  // private function insertKey($key_parts, $prefix, $set)
  // {
  //   $key = $this->buildKey($key_parts, $prefix);
  //   $this->_redis->sadd($set, $key);
  //   return $key;
  // }

  // private function buildKey($key_parts, $prefix)
  // {
  //   return $prefix.(is_array($key_parts) ? implode("\\", $key_parts) : "\\".$key_parts);
  // }

  private function insertContainmentRelationship($contained_element,
                                                 $contained_type,
                                                 $container_type,
                                                 $container = null)
  {
    if ($container) {

      $this->_redis->sadd("{$container}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container);

    } elseif ($container = $this->_redis->lrange('scope', 0, 0) && isset($container[0])) {

      $this->_redis->sadd("{$container[0]}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container[0]);

    }
  }

  private function populateIteratively($statements, $key)
  {
    $this->_redis->lpush('scope', $key);
    $this->populate($statements);
    $this->_redis->lpop('scope');
  }

  // private function insertAssignement(PHPParser_Node_Expr_Assign $node_object)
  // {
  //   // var_dump(get_class($node_object->var), $node_object->var->name);
  //   $this->insertLeftValue($node_object->var);
  //   // if ($node_object->var instanceof PHPParser_Node_Expr_Variable)
  //   // elseif ($node_object->var->name instanceof PHPParser_Node_Expr_Variable)
  //   //   $this->insertLeftValue($node_object->var->name);
  //   // elseif ($node_object->var->name instanceof String)
  //   //   $this->insert("variable {$node_object->var->name}");
  // }

  // private function insertLeftValue(PHPParser_Node_Expr $node_object)
  // {
  //   if ($node_object->name instanceof PHPParser_Node_Expr_Variable)
  //     $this->insertVariable($node_object->name, $node_object->var);
  //   // elseif ($node_object->name instanceof PHPParser_Node_Expr_Variable)
  //   //   $this->insertLeftValue($node_object->name);
  //   // elseif ($node_object->name instanceof PHPParser_Node_Expr_ArrayDimFetch)
  //   //   $this->_redis->sadd($node, );
  // }

  // private function insertVariable($node, $right_expression)
  // {
  //   if ($node->name instanceof PHPParser_Node_Expr_Variable)
  //     $this->insertVariable($node->name);
  //   else {
  //     $scope = $this->_redis->lrange('scope', 0, 0);
  //     $scope = $scope ? $scope[0] : '';
  //     $variable_key = $this->buildKey($node->name, $scope);
  //     $this->_redis->sadd($variable_key, $this->getRightValue($right_expression));
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
