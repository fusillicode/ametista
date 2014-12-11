require 'nori'
require_relative 'utilities'

class JSONifier
  extend Forwardable
  extend Initializer
  initialize_with ({
    parser: Nori.new(
      :convert_dashes_to_underscores => false
    )
  })
  def_delegator :@parser, :parse, :jsonify
end
