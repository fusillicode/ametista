require_relative 'builder'
require_relative '../schema'

class VersionsBuilder < Builder

  def version variable, ast
    Version.create(
      variable: variable,
      position: querier.position(ast)
    )
  end

end
