require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/properties_querier'

class PropertiesBuilder

  extend Initializer
  initialize_with ({
    querier: PropertiesQuerier.new
  })

  def build ast
    @ast = ast
  end

end

