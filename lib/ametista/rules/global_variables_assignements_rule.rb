require_relative '../schema'
require_relative '../queriers/assignements_querier'
require_relative 'rule'
require_relative 'rules_collection'

class GlobalVariablesAssignementsRule < RulesCollection

  attribute :querier, Querier, default: AssignementsQuerier.new

  def apply
    GlobalVariable.find_each do |global_variable|
      global_variable.types << types(versions_types(global_variable))
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
