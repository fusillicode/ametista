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
  attribute :last_application, Hash, default: Hash.new

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
      current_types = global_variable.types
      new_types = types_for_klass_methods_calls content, global_variable
      if model_modified = last_application[global_variable.id] != new_types
        global_variable.types = new_types
      end
      last_application[global_variable.id] = new_types
      model_modified
    end
  end

  def types_for_klass_methods_calls content, global_variable
    querier.klass_methods_calls(content, global_variable.name).map do |klass_method_call|
      inferred_types = types_for_klass_method_call klass_method_call
      current_types = global_variable.types
      return inferred_types if current_types.empty?
      intersection_of_types = current_types & inferred_types
      return intersection_of_types if not(intersection_of_types.empty?)
      return current_types & inferred_types
    end
  end

  def types_for_klass_method_call klass_method_call
    KlassMethod.where(name: querier.name(klass_method_call)).map do |klass_method|
      klass_method.klass.descendants
    end
  end

end
