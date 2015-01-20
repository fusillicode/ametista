require_relative 'builder'
require_relative '../schema'

class VersionsBuilder < Builder

  def version variable, ast
    # TODO rimuovere il check sul rhs quando Postgres consentirà l'inserimento
    # di stringhe vuote per il campo xml
    rhs = querier.rhs(ast)
    Version.create!(
      variable: variable,
      position: querier.position(ast),
      rhs: (rhs.empty? ? ' ' : rhs)
    )
  end

end
