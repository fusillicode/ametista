require_relative 'querier'

class ParametersAstQuerier < Querier

  def function_parameters ast
    ast.xpath('.//node:Stmt_ClassMethod/subNode:params/scalar:array/node:Param')
  end

  def klasses_methods_parameters ast
    ast.xpath('.//node:Stmt_Function/subNode:params/scalar:array/node:Param')
  end

  def parent_function_name ast
    ast.xpath("./ancestor::node:Stmt_Function/subNode:name/scalar:string").text
  end

  def parent_klass_method_name ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod/subNode:name/scalar:string").text
  end

  def parent_function_unique_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\') +
    '\\' +
    parent_name(ast)
  end

  def parent_klass_method_unique_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\') +
    '\\' +
    parent_name(ast)
  end

  def parameters ast
    function_parameters(ast) + klasses_methods_parameters(ast)
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    "#{parent_unique_name(ast)}\\#{name(ast)}"
  end

  def parent_type ast
    entity_mapper[ast.xpath("name(./ancestor::*[name() = 'node:Stmt_ClassMethod' or name() = 'node:Stmt_Function'][1])")]
  end

  def parent_name ast
    ast.xpath("./ancestor::*[name() = 'node:Stmt_ClassMethod' or name() = 'node:Stmt_Function'][1]/subNode:name/scalar:string").text
  end

  def parent_unique_name ast
    # Stmt_ClassMethod
    class_unique_name = ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')
    return class_unique_name[0..-1].to_a.join('\\') + '\\' + parent_name(ast) unless class_unique_name.empty?
    # Stmt_Function
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\') + '\\' + parent_name(ast)
  end

  def type ast
    type = ast.xpath("./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]")
    return if type.empty?
    entity_mapper[type]
  end

  def type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def type_unique_name ast
    parameter_type_unique_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    parameter_type_unique_name
  end

end
