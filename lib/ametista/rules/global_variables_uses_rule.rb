require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/uses_querier.rb'

# StaticCall
# MethodCall
# FuncCall
# PropertyFetch
# StaticPropertyFetch
# ConstFetch
# ArrayDimFetch

class GlobalVariablesUsesRule < RulesCollection

  include Virtus.model
  attribute :querier, Querier, default: UsesQuerier.new

  def apply
    apply_on_namespaces_contents
  end

  def apply_on_namespaces_contents
    Content.namespaces_contents.find_each do |content|
      content = parser.parse content.statements
      types_for_global_variables_uses content
    end
  end

  def types_for_global_variables_uses content
    GlobalVariable.find_each do |global_variable|
      ap types_for_klass_methods_calls(content, global_variable.name) | global_variable.types
    end
  end

  def types_for_klass_methods_calls content, name
    querier.klass_methods_calls(content, name).map do |klass_method_call|
      types klass_method_call
    end.flatten
  end

  def types klass_method_call
    KlassMethod.where(name: querier.name(klass_method_call)).map do |klass_method|
      klass_method.klass
    end
  end

end
