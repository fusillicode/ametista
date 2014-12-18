require_relative '../schema.rb'
require_relative '../queriers/querier'

class Builder
  extend Initializer
  initialize_with ({
    querier: Querier.new,
    ast: nil
  })
  # TODO rimuovere il check sui statements quando Postgres consentirà l'inserimento
  # di stringhe vuote per il campo xml
  def content statements
    Content.new({ statements: (statements.empty? ? ' ' : statements) })
  end
end
