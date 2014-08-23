require_relative 'querier'

class GlobalVariablesAstQuerier < Querier

  def global_variables
    # assegnamenti namespace globale
    ast.xpath(".//node:Expr_Assign[not(ancestor::node:Stmt_Namespace or ancestor::node:Stmt_ClassMethod or ancestor::node:Stmt_Function)]")
    # ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')
    # ast.xpath('//subNode:stmts/scalar:array/*[name() = "node:Expr_Assign" or name() = "node:Stmt_Global"]')
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
