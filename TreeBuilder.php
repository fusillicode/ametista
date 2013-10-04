<?php

class TreeBuilder
{
  public function __construct()
  {
    $this->tree = new Judy(Judy::STRING_TO_MIXED);
  }

  public function buildTree(array $statements)
  {
    $current_tree_root =& $this->tree;
    foreach ($statements as $key => $node_object)
      $this->growTree($node_object, $current_tree_root);
    return $this->tree;
  }

  private function growTree(PHPParser_Node $node_object, $current_tree_root)
  {
    $this->insertNode($node_object);
    if (!empty($node_object->stmts))
      $this->tree = $this->buildTree($node_object->stmts);
    $this->tree =& $current_tree_root;
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
    foreach ($node_object->name->parts as $key => $sub_namespace_name)
      $this->insert("namespace $sub_namespace_name");
  }

  private function insertClass(PHPParser_Node_Stmt_Class $node_object)
  {
    $this->insert("class {$node_object->name}");
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

  private function insert($new_parent)
  {
    $this->tree[$new_parent] = new Judy(Judy::STRING_TO_MIXED);
    $this->tree =& $this->tree[$new_parent];
  }

}

?>