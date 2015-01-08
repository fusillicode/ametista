require_relative '../queriers/querier'

class Rule
  extend Initializer
  initialize_with ({
    querier: Querier.new
  })
end
