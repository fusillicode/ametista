require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/uses_querier.rb'

class GlobalVariablesUsesRule < RulesCollection

  include Virtus.model
  attribute :querier, UsesQuerier, default: UsesQuerier.new

  def apply
    GlobalVariable.find_each do |global_variable|
      global_variable.types << types(versions_type(global_variable))
    end
  end

  def versions_type global_variable
    global_variable.versions.all.map do |version|
      version_type version
    end
  end

  def version_type version
    rhs = parser.parse version.rhs
    rhs_kind = querier.rhs_kind(rhs)
    apply_rule rhs_kind, rhs
  end

  def types types_names
    Type.where :name => types_names
  end

end
