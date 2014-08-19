require_relative 'querier'

class AnAssignementAstQuerier < Querier

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
    namespace = namespace
    if function != ''
      return { function: namespace + function }
    elsif method = method != ''
      class = class
      return { class: namespace + class + method }
    else
      return { namespace: namespace }
    end
  end

  def namespace ast
    namespace_parts = ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    global_namespace_unique_name + namespace_parts.map{ |namespace_part| "\\#{namespace_part.text}" }.join
  end

  def function ast
    ast.xpath('./ancestor::node:Stmt_Function[1]/subNode:name/scalar:string').text
  end

  def method ast
    ast.xpath('./ancestor::node:Stmt_ClassMethod[1]/subNode:name/scalar:string').text
  end

  def class ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

  def branch ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

end
