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
    $this->_current_namespace = '';
    $this->_current_class = '';
    $this->_current_procedure = '';
    $this->_redis->sadd('types', array('boolean',
                                        'int',
                                        'double',
                                        'string',
                                        'array',
                                        'stdClass'));
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
    return $this->get();
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
    foreach ($node_object->name->parts as $key => $sub_namespace_name) {
      $parent_namespace = $this->_current_namespace;
      $this->_current_namespace .= "\\{$sub_namespace_name}";
      $this->_redis->sadd("{$parent_namespace}:[N", $this->_current_namespace);
      $this->_redis->sadd("{$this->_current_namespace}:]N", $parent_namespace);
    }
    $this->populate($node_object->stmts);
  }

  private function insertClass(PHPParser_Node_Stmt_Class $node_object)
  {
    $this->_current_class = $this->createKey($node_object->namespacedName->parts, 'C:');
    $this->insertSuperclass($node_object);
    $this->_redis->sadd("types", $this->_current_class);
    $this->populate($node_object->stmts);
  }

  private function createKey($key_parts, $type)
  {
    return $type.(isset($key_parts[0]) ?
                  implode("\\", $key_parts) :
                  "\\".$key_parts);
  }

  private function insertSuperclass(PHPParser_Node_Stmt_Class $node_object)
  {
    if (!$superclass = $node_object->extends) return false;
    $superclass_key = $this->createKey($superclass->parts, 'C:');
    $this->_redis->sadd("{$this->_current_class}>", $superclass_key);
    $this->_redis->sadd("{$superclass_key}<", "{$this->_current_class}");
  }

  // private function updateInsertedClassKeys($class_name, $class_key)
  // {
  //   if (!$class_references = $this->_redis->keys($class_name)) return false;
  //   foreach ($class_references as $key => $class_reference) {
  //     $this->_redis->sadd(str_replace($class_reference,
  //                                     $class_key,
  //                                     $class_reference),
  //                         $this->_redis->smembers($class_reference));
  //     $this->_redis->del($class_reference);
  //   }
  // }

  private function insertFunction(PHPParser_Node_Stmt_Function $node_object)
  {
    $this->_current_procedure = $this->createKey($node_object->namespacedName->parts, 'F:');
    $this->populate($node_object->statements);
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {

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
