require_relative '../queriers/model_querier'

class Rule
  extend Initializer
  initialize_with ({
    querier: ModelQuerier.new
  })
end
