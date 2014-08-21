require_relative '../utilities'
require_relative '../php_language'
require_relative 'builder'

class LanguageBuilder < Builder

  extend Initializer
  initialize_with ({
    language: PHPLanguage.new
  })

  def build
    build_types
    build_superglobals
  end

  def build_types
    language.types.each do |type|
      BasicType.create(
        unique_name: type,
        name: type
      )
    end
  end

  def build_superglobals
    language.superglobals.each do |superglobal|
      GlobalVariable.create(
        unique_name: superglobal,
        name: superglobal
      )
    end
  end

end
