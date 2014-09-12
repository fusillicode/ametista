require_relative 'builder'
require_relative '../utilities'

class LanguageBuilder < Builder

  extend Initializer
  initialize_with ({
    lang: {
      unique_name: 'PHP',
      name: 'PHP',
      global_namespace: {
        unique_name: '\\',
        name: '\\'
      },
      namespace_separator: '\\',
      superglobals: [
        # 'GLOBALS', in the $GLOBALS array are stored all the 'normal' global variables so
        # even if it is actually considered a superglobals, here it is not considered
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
      property: ['this']
    }
  })

  def build
    Language.find_or_create_by(lang)
  end

end
