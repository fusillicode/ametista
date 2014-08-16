require_relative '../utilities'
require_relative '../php_language'

class LanguageBuilder

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
      AType.create(name: type)
    end
  end

  def build_superglobals
    language.superglobals.each do |superglobal|
      AGlobalVariable.create(:unique_name => superglobal)
    end
  end

end
