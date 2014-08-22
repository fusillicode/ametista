require_relative 'utilities'
require_relative 'php_language'
require_relative 'schema'

class EntityMapper
  extend Initializer
  initialize_with ({
    language: PHPLanguage.new,
    default_map_value: CustomType,
    map: {
      'node:Stmt_Function'    => Function,
      'node:Stmt_ClassMethod' => KlassMethod
    }
  })

  def initialize
    super
    init_map
  end

  def init_map
    @map.default = default_map_value
    language.types.each do |basic_type|
      @map[basic_type.to_sym] = BasicType
    end
  end

  # TODO implementare anche respond_to?
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif language.respond_to? method_name
      language.public_send method_name, *args, &block
    elsif map.respond_to? method_name
      map.public_send method_name, *args, &block
    else
      super
    end
  end

end
