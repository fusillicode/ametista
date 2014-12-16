require_relative '../queriers/querier'

class Builder
  extend Initializer
  initialize_with ({
    querier: Querier.new,
    ast: nil
  })
end
