require_relative 'utilities'
require_relative 'php_language'
require_relative 'schema'

class EntityMapper
  extend Initializer
  initialize_with ({
    language: PHPLanguage.new,
    map: Hash.new(CustomType)
  })

  def initialize
    super
    @language.types.each do |basic_type|
      @map[basic_type.to_sym] = BasicType
    end
  end

end
