require_relative 'builder'
require_relative '../queriers/versions_querier'
require_relative '../schema'

class VersionsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: VersionsQuerier.new
  })

  def global_definition_versions global_variable, global_definition_ast
    querier.global_definition_versions(
      global_variable.name,
      global_definition_ast
    ).map_unique('id') do |global_definition_version_ast|
      version(global_variable, global_definition_version_ast)
    end
  end

  def version variable, ast
    # TODO rimuovere il check sul rhs quando Postgres consentirà l'inserimento
    # di stringhe vuote per il campo xml
    rhs = querier.rhs(ast)
    Version.create(
      variable: variable,
      position: querier.position(ast),
      rhs: (rhs.empty? ? ' ' : rhs)
    )
  end

end
