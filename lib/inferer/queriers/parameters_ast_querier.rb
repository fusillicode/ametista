require_relative 'querier'

class ParametersAstQuerier < Querier

  def parameters
    ast.xpath('.//node:Param')
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
    return global_namespace_unique_name + class_unique_name[0..-1].to_a.join('\\') + '\\' + parent_name(ast) unless class_unique_name.empty?
    # Stmt_Function
    global_namespace_unique_name + ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\') + '\\' + parent_name(ast)
  end

  def type ast
    entity_mapper[ast.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]]")]
  end

  def type_name ast
    parameter_type_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
    return parameter_type_name if parameter_type_name != ''
    ast.xpath('./subNode:name/scalar:string').text
  end

  def type_unique_name ast
    parameter_type_unique_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    return global_namespace_unique_name + parameter_type_unique_name if parameter_type_unique_name != ''
    global_namespace_unique_name + ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
