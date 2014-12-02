require_relative '../schema'
require_relative '../queriers/querier'

class UsageAnalyzer

  extend Initializer
  initialize_with ({
    querier: Querier.new
  })

  def analyze

  end

end
