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
      global_variables_uses content
    end
  end

  def global_variables_uses content
    GlobalVariable.find_each do |global_variable|
      klass_methods_calls(content, global_variable.name)
    end
  end

  def klass_methods_calls content, name
    querier.klass_methods_calls(content, name).map do |klass_method_call|
      klasses_unique_names klass_method_call
    end
  end

  def klasses_unique_names klass_method_call
    KlassMethod.where(name: querier.name(klass_method_call)).map do |klass_method|
      klass_method.klass.unique_name
    end
  end

  def types types_names
    Type.where unique_name: types_names
  end

end
