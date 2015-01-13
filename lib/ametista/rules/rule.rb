require_relative '../xml_parser'
require_relative '../queriers/querier'

class Rule
  extend Initializer
  initialize_with ({
    querier: Querier.new,
    parser: XmlParser.new
  })
end
