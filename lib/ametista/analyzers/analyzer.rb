require_relative '../queriers/querier'
require_relative '../xml_parser'

class Analyzer
  extend Initializer
  initialize_with ({
    querier: Querier.new,
    parser: XMLParser.new
  })
end
