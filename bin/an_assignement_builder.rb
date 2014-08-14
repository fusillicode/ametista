require_relative 'utilities'
require_relative 'model'

class AnAssignementBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    parent_unique_name: '\\',
    querier: nil,
  })

  def build args
    @ast ||= args[:ast]
    @parent_unique_name ||= args[:parent_unique_name]
  end

  def assignement
    # AnAssignement.find_or_create_by(
    #   unique_name: '\\',
    #   name: '\\'
    # )
  end

end

