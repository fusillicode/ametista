require_relative 'querier'

class ParametersQuerier < Querier

  def functions_parameters ast
    ast.xpath('.//node:Stmt_Function/subNode:params/scalar:array/node:Param')
  end

  def klasses_methods_parameters ast
    ast.xpath('.//node:Stmt_ClassMethod/subNode:params/scalar:array/node:Param')
  end

  def function_parameter_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass_method_parameter_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def function_parameter_unique_name ast
    "#{parent_function_unique_name(ast)}#{language.namespace_separator}#{function_parameter_name(ast)}"
  end

  def parent_function_unique_name ast
    "#{parent_namespace_unique_name(ast)}#{language.namespace_separator}#{parent_function_name(ast)}"
  end

  def parent_namespace_unique_name ast
    "#{global_namespace_unique_name}#{language.namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def parent_function_name ast
    ast.xpath("./ancestor::node:Stmt_Function/subNode:name/scalar:string").text
  end

  def klass_method_parameter_unique_name ast
    "#{parent_klass_method_unique_name(ast)}#{language.namespace_separator}#{klass_method_parameter_name(ast)}"
  end

  def parent_klass_method_unique_name ast
    "#{parent_klass_unique_name(ast)}#{language.namespace_separator}#{parent_klass_method_name(ast)}"
  end

  def parent_klass_unique_name ast
    "#{global_namespace_unique_name}#{language.namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def parent_klass_method_name ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod/subNode:name/scalar:string").text
  end

end
