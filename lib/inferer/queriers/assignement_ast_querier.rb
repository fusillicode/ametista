require_relative 'querier'
require 'ostruct'

class AssignementAstQuerier < Querier

  def assignements
    ast.xpath('//node:Expr_Assign')
  end

  def variable ast
    ast.xpath('./subNode:var')
  end

  def rhs ast
    ast.xpath('./subNode:expr').to_s
  end

  def scope ast
    # l'ordine degli delle condizioni è rilevante
    if branch = branch_scope(ast)
      OpenStruct.new(
        type: Branch,
        unique_name: branch,
        name: name(brach)
      )
    elsif function = function_scope(ast)
      OpenStruct.new(
        type: Function,
        unique_name: function,
        name: name(function)
      )
    elsif method = method_scope(ast)
      OpenStruct.new(
        type: Method,
        unique_name: method,
        name: name(method)
      )
    else
      namespace = namespace_scope(ast)
      OpenStruct.new(
        type: Namespace,
        unique_name: namespace,
        name: name(namespace)
      )
    end
  end

  def name unique_name
    unique_name.split('\\').last
  end

  def namespace_scope ast
    namespace_parts = ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    global_namespace_unique_name + namespace_parts.map{ |namespace_part| "\\#{namespace_part.text}" }.join
  end

  def function_scope ast
    function = ast.xpath('./ancestor::node:Stmt_Function[1]/subNode:name/scalar:string').text
    return false if function == ''
    "#{namespace_scope(ast)}\\#{function}"
  end

  def method_scope ast
    method = ast.xpath('./ancestor::node:Stmt_ClassMethod[1]/subNode:name/scalar:string').text
    return false if method == ''
    "#{namespace_scope(ast)}\\#{class_scope(ast)}\\#{method}"
  end

  def branch_scope ast
    # TODO trattare tutti i casi di branch...
    # TODO trattare i branch innestati!!!
    branch = ast.xpath('./ancestor::node:Stmt_Branch[1]/subNode:name/scalar:string').text
    return false if branch == ''
    if function = function_scope(ast)
      "#{function}\\#{branch}"
    elsif method = method_scope(ast)
      "#{method}\\#{branch}"
    else
      "#{namespace_scope(ast)}\\#{branch}"
    end
  end

  def class_scope ast
    a_class = ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
    return false if a_class == ''
    a_class
  end

end
