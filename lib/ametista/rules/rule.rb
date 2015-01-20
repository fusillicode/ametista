require_relative '../xml_parser'
require_relative '../queriers/querier'

class Rule

  extend Initializer
  initialize_with ({
    parser: XmlParser.new,
    querier: Querier.new
  })

end
