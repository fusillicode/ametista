require_relative 'assignement_querier'

class GlobalVariablesQuerier < AssignementQuerier

  def global_namespace_variables ast_root
    ast_root.xpath("/AST/array/node:Expr_Assign/descendant::node:Expr_Variable[subNode:name/string[#{not_a_superglobal}]]")
  end

  def global_definitions ast_root
    ast_root.xpath(".//node:Stmt_Global/subNode:vars/array/descendant::node:Expr_Variable[subNode:name/string[#{not_a_superglobal}]]")
  end

  def superglobals ast_root
    ast_root.xpath(".//node:Expr_Assign/descendant::node:Expr_ArrayDimFetch[last()][subNode:var/node:Expr_Variable[subNode:name/string[#{a_superglobal}]]]")
  end

  def global_namespace_variable_name ast
    ast.xpath("./subNode:name/string").text
  end

  def global_definition_name ast
    ast.xpath("./subNode:name/string").text
  end

  def superglobal_type ast
    ast.xpath('./subNode:var/node:Expr_Variable/subNode:name/string').text
  end

  def superglobal_name ast
    ast.xpath('./subNode:dim/node:Scalar_String/subNode:value/string').text
  end

  # def variable_unique_name
  #   p 'namespace: ' << ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/string').text
  #   p 'function: ' << ast.xpath('./ancestor::node:Stmt_Function[1]/subNode:name/string').text
  #   p 'class: ' << ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/string').text
  #   p 'method: ' << ast.xpath('./ancestor::node:Stmt_ClassMethod[1]/subNode:name/string').text
  #   p '###########################'
  # end

  # def variable_name(ast)

  #   node = ast.xpath('./*[1]')[0]

  #   case node.name
  #   when 'Expr_Variable'
  #     name = node.xpath('./subNode:name/string').text
  #     # non tratto le variabili di variabli (e.g. $$v)
  #     return false if name.nil? or name.empty?
  #     # le variabili plain assegnate sono comunque in GLOBALS
  #     return "GLOBALS[#{name}]" if name != 'GLOBALS'
  #     name
  #   when 'Expr_PropertyFetch'
  #     # non tratto proprietà con nomi dinamici
  #     return false if !var = variable_name(node.xpath('./subNode:var'))
  #     return false if !name = variable_name(node.xpath('./subNode:name'))
  #     var << '->' << name
  #   when 'Expr_ArrayDimFetch'
  #     # non tratto indici di array dinamici
  #     return var if !var = variable_name(node.xpath('./subNode:var'))
  #     dim = node.xpath('./subNode:dim/*[name() = "node:Scalar_String" or name() = "node:Scalar_LNumber"]/subNode:value/*').text
  #     return false if dim.nil? or dim.empty?
  #     var << '[' << dim << ']'
  #   when 'string'
  #     node.text
  #   else
  #     false
  #   end

  # end

end
