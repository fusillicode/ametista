require_relative 'querier'

class ParametersAstQuerier < Querier

  def parameters ast
    function_parameters(ast) + klasses_methods_parameters(ast)
  end

  # TODO QUESTO POTREBBE ESSERE RISCRITTO TIPO parent_klass_method_name(ast) or parent_function_name(ast)
  def parent_name ast
    parent_klass_method_name = parent_klass_method_name(ast)
    return parent_klass_method_name unless parent_klass_method_name.empty?
    parent_function_name(ast)
    # ast.xpath("./ancestor::*[name() = 'node:Stmt_ClassMethod' or name() = 'node:Stmt_Function'][1]/subNode:name/scalar:string").text
  end

  # TODO QUESTO POTREBBE ESSERE RISCRITTO TIPO parent_klass_method_unique_name(ast) or parent_function_unique_name(ast)
  def parent_unique_name ast
    parent_klass_method_unique_name = parent_klass_method_unique_name(ast)
    # TODO CHIEDERE SE ESISTE DAVVERO BLANK? NELLA STD DI RUBY
    return parent_klass_method_unique_name unless parent_klass_method_unique_name.empty?
    parent_function_unique_name(ast)
  end

  def parent_type ast
    entity_mapper[ast.xpath("name(./ancestor::*[name() = 'node:Stmt_ClassMethod' or name() = 'node:Stmt_Function'][1])")]
  end

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
    # TODO, ATTENZIONE CHE \\ VIENE AGGIUNTO ANCHE SE NON HO NESSUN NAMESPACE OVVERO SE HO UNA FUNZIONE NEL NAMESPACE GLOBALE
    parent_namespace_unique_name(ast) + '\\' + parent_function_name(ast)
  end

  def parent_namespace_unique_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def parent_klass_method_unique_name ast
    parent_klass_unique_name = parent_klass_unique_name(ast)
    return parent_klass_unique_name + '\\' + parent_klass_method_name(ast) unless parent_klass_unique_name.empty?
  end

  def parent_klass_unique_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    "#{parent_unique_name(ast)}\\#{name(ast)}"
  end

  def type ast
    type = type_name(ast)
    return if type.empty?
    entity_mapper[type]
  end

  def type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def type_unique_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
