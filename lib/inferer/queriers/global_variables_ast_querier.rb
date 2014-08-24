require_relative 'querier'

class GlobalVariablesAstQuerier < Querier

  def global_variables
    assignements_in_global_namespace +
    global_definitions +
    assignements_to_superglobals
  end

  def assignements_in_global_namespace
    ast.xpath("/AST/scalar:array/node:Expr_Assign")
  end

  def global_definitions
    ast.xpath(".//node:Stmt_Global")
  end

  def assignements_to_superglobals
    ast.xpath(".//node:Expr_Assign[subNode:var/node:Expr_ArrayDimFetch/subNode:var/node:Expr_Variable/subNode:name/scalar:string[#{superglobals_list}]]")
  end

  def superglobals_list
    language.superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(' or ')
  end

  def variable_unique_name
    p 'namespace: ' << ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/scalar:string').text
    p 'function: ' << ast.xpath('./ancestor::node:Stmt_Function[1]/subNode:name/scalar:string').text
    p 'class: ' << ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
    p 'method: ' << ast.xpath('./ancestor::node:Stmt_ClassMethod[1]/subNode:name/scalar:string').text
    p '###########################'
  end

  def variable_name(ast)

    node = ast.xpath('./*[1]')[0]

    case node.name
    when 'Expr_Variable'
      name = node.xpath('./subNode:name/scalar:string').text
      # non tratto le variabili di variabli (e.g. $$v)
      return false if name.nil? or name.empty?
      # le variabili plain assegnate sono comunque in GLOBALS
      return "GLOBALS[#{name}]" if name != 'GLOBALS'
      name
    when 'Expr_PropertyFetch'
      # non tratto proprietà con nomi dinamici
      return false if !var = variable_name(node.xpath('./subNode:var'))
      return false if !name = variable_name(node.xpath('./subNode:name'))
      var << '->' << name
    when 'Expr_ArrayDimFetch'
      # non tratto indici di array dinamici
      return var if !var = variable_name(node.xpath('./subNode:var'))
      dim = node.xpath('./subNode:dim/*[name() = "node:Scalar_String" or name() = "node:Scalar_LNumber"]/subNode:value/*').text
      return false if dim.nil? or dim.empty?
      var << '[' << dim << ']'
    when 'string'
      node.text
    else
      false
    end

  end

end
