require_relative '../queriers/ast_querier'

class Rule
  extend Initializer
  initialize_with ({
    querier: AstQuerier.new
  })
end
