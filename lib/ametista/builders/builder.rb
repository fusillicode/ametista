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
  def content xml
    Content.create(
      statements: (xml.empty? ? ' ' : xml)
    )
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      name: querier.namespace_name(name_parts)
    )
  end
end
