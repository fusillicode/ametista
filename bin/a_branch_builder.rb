require_relative 'initializer'
require_relative 'model'

class ABranchBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    querier: nil,
  })

end

