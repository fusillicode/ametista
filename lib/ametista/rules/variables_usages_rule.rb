require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/assignements_querier.rb'

class VariablesUsesRule < Rule

  include Virtus.model
  attribute :querier, AssignementsQuerier, default: AssignementsQuerier.new



end
