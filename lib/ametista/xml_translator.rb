require 'nori'
require_relative 'utilities'

class XMLTranslator

  extend Initializer
  initialize_with ({
    parser: Nori.new(
      :convert_dashes_to_underscores => false
    )
  })

  def to_json xml
    parser.parse xml
  end

end
