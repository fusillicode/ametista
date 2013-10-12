<?php

class Model
{
  public function __construct()
  {
    try {
      $this->_redis = new Predis\Client();
      $this->_redis->connect();
      $this->_current_namespace = 'n:global';
      $this->_current_class = null;
      $this->_current_procedure = null;
      echo "Successfully connected to Redis server\n";
      return true;
    } catch (Exception $e) {
      exit("Couldn't connected to Redis server\n{$e->getMessage()}\n");
    }
  }

  public function populate(array $statements)
  {
    foreach ($statements as $key => $node_object) {
      $this->insertNode($node_object);
      if (!empty($node_object->stmts)) $this->populate($node_object->stmts);
    }
    return $this->_redis;
  }

  private function insertNode(PHPParser_Node $node_object)
  {
    switch (get_class($node_object)) {
      case 'PHPParser_Node_Stmt_Namespace':
        $this->insertNamespace($node_object);
        break;
      // case 'PHPParser_Node_Stmt_Class':
      //   $this->insertClass($node_object);
      //   break;
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
      $this->_redis->sadd("{$parent_namespace}:contain", $this->_current_namespace);
      $this->_redis->sadd("{$this->_current_namespace}:containedIn", $parent_namespace);
    }
  }

  private function insertClass(PHPParser_Node_Stmt_Class $node_object)
  {
    $this->_current_class = $node_object->name;
    $this->updateAlreadyInsertedClassReferences($this->_current_class);
    if ($parent_class = $node_object->extends) {
      $parent_class = $this->_redis->keys($parent_class);
      $parent_class = $parent_class ? $parent_class : ;
      $this->_redis->sadd("{$this->_current_namespace}c:{$_current_class}:subclassOf", $parent_class);
      $this->_redis->sadd($parent_class, "{$this->_current_namespace}c:{$_current_class}:parentClassOf");
    }
    $this->_redis->sadd($this->_current_namespace, "{$this->_current_namespace}c:{$_current_class}");
  }

  private function updateAlreadyInsertedClassReferences($class_name)
  {
    if (!$class_references = $this->_redis->keys($class_name)) return false;
    foreach ($class_references as $key => $class_reference) {
      $this->_redis->sadd(str_replace($class_reference,
                                      "{$this->_current_namespace}c:{$class_name}",
                                      $class_reference),
                          $this->_redis->smembers($class_reference));
      $this->_redis->del($class_reference);
    }
  }

  private function insertFunction(PHPParser_Node_Stmt_Function $node_object)
  {
    $this->insert("function {$node_object->name}");
  }

  private function insertClassMethod(PHPParser_Node_Stmt_ClassMethod $node_object)
  {
    $this->insert("classMethod {$node_object->name}");
  }

  private function insertAssignement(PHPParser_Node_Expr_Assign $node_object)
  {
    if ($node_object->var instanceof PHPParser_Node_Expr_Variable)
      $this->insertVariable($node_object->var);
    elseif ($node_object->var->name instanceof PHPParser_Node_Expr_Variable)
      $this->insertVariable($node_object->var->name);
    elseif ($node_object->var->name instanceof String)
      $this->insert("variable {$node_object->var->name}");
  }

  private function insertVariable(PHPParser_Node_Expr_Variable $node_object)
  {
    if ($node_object->name instanceof PHPParser_Node_Expr_Variable)
      $this->insertVariable($node_object->name);
    else
      $this->insert("variable {$node_object->name}");
  }

}

?>
