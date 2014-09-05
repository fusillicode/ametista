require_relative 'querier'

class GlobalVariablesAstQuerier < Querier

  def global_variables
    global_namespace_variables << global_definitions << superglobals
  end

  def global_namespace_variables
    ast.xpath("/AST/scalar:array/node:Expr_Assign/descendant::node:Expr_Variable[subNode:name/scalar:string[not(#{superglobals_list('and')})]]")
  end

  def global_definitions
    ast.xpath(".//node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable")
  end

  def superglobals
    ast.xpath(".//node:Expr_Assign/descendant::node:Expr_ArrayDimFetch[last()][subNode:var/node:Expr_Variable[subNode:name/scalar:string[#{superglobals_list('or')}]]]")
  end

  def superglobals_list operator
    language.superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(" #{operator} ")
  end

  def name ast
    superglobal_name(ast) or global_name(ast)
  end

  def superglobal_name ast
    name = ast.xpath('./subNode:var/subNode:name/scalar:string').text
    return if name.empty?
    ast.xpath('./subNode:dim/node:Scalar_String/subNode:value/scalar:string').text + "['#{name}']"
  end

  def global_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    name
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
