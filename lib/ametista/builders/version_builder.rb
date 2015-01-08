require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'

class VersionsBuilder < Builder

  def version ast
    Version.create(
      variable: variable,
      position: querier.position(ast)
    )
  end

end
