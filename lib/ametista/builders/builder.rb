require_relative '../schema.rb'
require_relative '../queriers/querier'

class Builder
  extend Initializer
  initialize_with ({
    querier: Querier.new,
    ast: nil
  })

  def content xml
    Content.create(
      statements: wrap_content(xml)
    )
  end

  # Necessario per assicurarsi che gli xml ritornati siano parsabili da Nokogiri
  # TODO rimuovere il check sui statements quando Postgres consentirà l'inserimento
  # di stringhe vuote per il campo xml
  def wrap_content xml
    xml.empty? ? ' ' : "<dummy_wrap>#{xml}</dummy_wrap>"
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      name: querier.namespace_name(name_parts)
    )
  end
end
