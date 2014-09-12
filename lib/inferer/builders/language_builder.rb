require_relative '../utilities'
require_relative '../php_language'

class LanguageBuilder

  extend Initializer
  initialize_with ({
    language: PHPLanguage.new
  })

  def build
    build_primitive_types
    build_superglobals
  end

  def build_primitive_types
    language.primitive_types.each do |primitive_type|
      PrimitiveType.create(
        unique_name: primitive_type,
        name: primitive_type
      )
    end
  end

  # TODO SISTEMARE LE SUPERGLOBAL
  def build_superglobals
    language.superglobals.each do |superglobal|
      GlobalVariable.create(
        unique_name: superglobal,
        name: superglobal
      )
    end
  end

end
