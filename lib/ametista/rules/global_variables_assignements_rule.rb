require_relative '../schema'
require_relative '../queriers/assignements_querier'
require_relative 'rule'
require_relative 'rules_collection'

class GlobalVariablesAssignementsRule < RulesCollection

  attribute :querier, Querier, default: AssignementsQuerier.new
  attribute :last_application, Hash, default: Hash.new

  def apply
    GlobalVariable.all.map do |global_variable|
      inferred_types = types versions_types(global_variable)
      current_types = global_variable.types
      new_types = current_types | inferred_types
      if model_modified = last_application[global_variable.id] != new_types
        global_variable.types = new_types
      end
      last_application[global_variable.id] = new_types
      model_modified
    end
  end

  def versions_types global_variable
    global_variable.versions.find_each.map do |version|
      version_types version
    end
  end

  def version_types version
    rhs = parser.parse version.rhs
    rhs_kind = querier.rhs_kind(rhs)
    apply_rule rhs_kind, rhs
  end

  def types types_names
    Type.where name: types_names
  end

end
