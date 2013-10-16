<?php

class Model
{
  public function __construct()
  {
    try {
      $this->_redis = new Predis\Client();
      $this->_redis->connect();
      echo "Successfully connected to Redis server\n";
    } catch (Exception $e) {
      exit("Couldn't connected to Redis server\n{$e->getMessage()}\n");
    }
    $this->_redis->sadd('scalar_types', array('boolean',
                                              'int',
                                              'double',
                                              'string',
                                              'array'));
    $this->_redis->sadd('classes', 'stdClass');
    return true;
  }

  public function build() {}

  public function delete()
  {
    return $this->_redis->flushall();
  }

  public function get()
  {
    return $this->_redis;
  }

  public function populate($statements)
  {
    if (!$statements) return false;
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
      case 'PHPParser_Node_Stmt_Function':
        $this->insertFunction($node_object);
        break;
      case 'PHPParser_Node_Stmt_ClassMethod':
        $this->insertClassMethod($node_object);
        break;
      // case 'PHPParser_Node_Expr_Assign':
      //   $this->insertAssignement($node_object);
      //   break;
    }
  }

  private function insertNamespace(PHPParser_Node_Stmt_Namespace $node_object)
  {
    $namespace_key = $this->buildKey($node_object->name->parts, 'N:\\');
    $this->_redis->sadd('namespaces', $namespace_key);
    $this->insertNamespaceHierarchy($node_object->name->parts);
    $this->_redis->lpush('scope', $namespace_key);
    $this->populate($node_object->stmts);
    $this->_redis->lpop('scope');
  }

  private function insertClass(PHPParser_Node_Stmt_Class $node_object)
  {
    $class_key = $this->buildKey($node_object->namespacedName->parts, 'C:\\');
    $this->_redis->sadd('classes', $class_key);
    $this->insertClassHierarchy($node_object, $class_key);
    $this->insertContainmentRelationship($class_key, 'C', 'N');
    $this->_redis->lpush('scope', $class_key);
    $this->populate($node_object->stmts);
    $this->_redis->lpop('scope');
  }

  private function insertFunction(PHPParser_Node_Stmt_Function $node_object)
  {
    $function_key = $this->buildKey($node_object->namespacedName->parts, 'F:\\');
    $this->_redis->sadd('functions', $function_key);
    $this->insertContainmentRelationship($function_key, 'F', 'N');
    $this->_redis->lpush('scope', $function_key);
    $this->populate($node_object->stmts);
    $this->_redis->lpop('scope');
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {
    $class = substr($this->_redis->lrange('scope', 0, 0)[0], 2);
    $method_key = $this->buildKey($node_object->name, "M:{$class}");
    $this->insertContainmentRelationship($method_key, 'M', 'C', $class);
    $this->_redis->lpush('scope', $method_key);
    $this->populate($node_object->stmts);
    $this->_redis->lpop('scope');
  }

  private function insertNamespaceHierarchy($namespace_name_parts)
  {
    if (!$namespace_name_parts) return false;
    $parent_namespace = $current_namespace = '\\';
    foreach ($namespace_name_parts as $key => $sub_namespace) {
      $current_namespace .= $sub_namespace;
      $this->_redis->sadd("N:{$parent_namespace}:[N", $current_namespace);
      $this->_redis->sadd("N:{$current_namespace}:]N", $parent_namespace);
    }
  }

  private function insertClassHierarchy(PHPParser_Node_Stmt_Class $node_object,
                                        $current_class_key)
  {
    if (!$superclass = $node_object->extends) return false;
    $superclass_key = $this->buildKey($superclass->parts, "C:\\");
    $this->_redis->sadd("{$current_class_key}:>", $superclass_key);
    $this->_redis->sadd("{$superclass_key}:<", $current_class_key);
  }

  private function insertContainmentRelationship($contained_element,
                                                 $contained_type,
                                                 $container_type,
                                                 $container = null)
  {
    if ($container) {
      $this->_redis->sadd("{$container}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container);
    } elseif ($container = $this->_redis->lrange('scope', 0, 0) &&
              isset($container[0])) {
      $this->_redis->sadd("{$container[0]}:[{$contained_type}", $contained_element);
      $this->_redis->sadd("{$contained_element}:]{$container_type}", $container[0]);
    }
  }

  private function buildKey($key_parts, $type)
  {
    return $type.(is_array($key_parts) ?
                  implode("\\", $key_parts) :
                  "\\".$key_parts);
  }

  private function insertAssignement(PHPParser_Node_Expr_Assign $node_object)
  {
    // if ($node_object->var instanceof PHPParser_Node_Expr_Variable)
    //   $this->insertVariable($node_object->var);
    // elseif ($node_object->var->name instanceof PHPParser_Node_Expr_Variable)
    //   $this->insertVariable($node_object->var->name);
    // elseif ($node_object->var->name instanceof String)
    //   $this->insert("variable {$node_object->var->name}");
  }

  private function insertVariable(PHPParser_Node_Expr_Variable $node_object)
  {
    // if ($node_object->name instanceof PHPParser_Node_Expr_Variable)
    //   $this->insertVariable($node_object->name);
    // else
    //   $this->insert("variable {$node_object->name}");
  }

}

?>
