require 'forwardable'
require_relative '../queriers/querier'
require_relative '../jsonifier'

class Builder
  extend Initializer
  extend Forwardable
  initialize_with ({
    querier: Querier.new,
    jsonifier: JSONifier.new,
    ast: nil
  })
  def_delegator :@jsonifier, :jsonify, :jsonify
end
