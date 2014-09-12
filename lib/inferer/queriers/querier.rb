require_relative '../utilities'
require_relative '../php_language'

class Querier

  extend Initializer
  initialize_with ({
    language: PHPLanguage.new
  })

  def global_namespace_name
    language.global_namespace[:name]
  end

  def global_namespace_unique_name
    language.global_namespace[:unique_name]
  end

  def a_superglobal
    language.superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(" or ")
  end

  def not_a_superglobal
    "not(#{a_superglobal})"
  end

  def a_property
    language.property.map{ |property| "text() = '#{property}'" }.join(" or ")
  end

  def not_a_property
    "not(#{a_property})"
  end

  def a_primitive_type
    language.primitive_types.map{ |primitive_type| "text() = '#{primitive_type}'" }.join(" or ")
  end

  def not_a_primitive_type
    "not(#{a_primitive_type})"
  end

end
