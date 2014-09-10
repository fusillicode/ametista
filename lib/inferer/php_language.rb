require_relative 'utilities'

class PHPLanguage

  extend Initializer
  initialize_with ({
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
    types: ['bool', 'int', 'double', 'string', 'array', 'resource', 'null', 'callback'],
    magic_constants: [
      'Scalar_LineConst',
      'Scalar_FileConst',
      'Scalar_DirConst',
      'Scalar_FuncConst',
      'Scalar_ClassConst',
      'Scalar_TraitConst',
      'Scalar_MethodConst',
      'Scalar_NSConst'
    ]
  })

end
