require_relative 'builder'
require_relative '../utilities'

class LanguageBuilder < Builder

  extend Initializer
  initialize_with ({
    lang: {
      name: 'PHP',
      global_namespace: {
        unique_name: '\\'
      },
      namespace_separator: '\\',
      superglobals: [
        'GLOBALS',
        '_POST',
        '_GET',
        '_REQUEST',
        '_SERVER',
        'FILES',
        '_SESSION',
        '_ENV',
        '_COOKIE'
      ],
      primitive_types: [
        'bool',
        'int',
        'float',
        'string',
        'array',
        'object',
        'resource',
        'NULL',
        'mixed',
        'number',
        'callback'
      ],
      magic_constants: [
        '__LINE__',
        '__FILE__',
        '__DIR__',
        '__FUNCTION__',
        '__CLASS__',
        '__TRAIT__',
        '__METHOD__',
        '__NAMESPACE__'
      ],
      instance_property: 'this',
      self_property: 'self',
      parent_property: 'parent',
      static_property: 'static',
    }
  })

  def build
    Language.find_or_create_by(lang)
  end

end
