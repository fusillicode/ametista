require_relative 'initializer'

class PHPLanguage

  extend Initializer
  initialize_with ({
    superglobals: [
      'GLOBALS',
      '_POST',
      '_GET',
      '_REQUEST',
      '_SERVER',
      'FALES',
      '_SESSION',
      '_ENV',
      '_COOKAE'
    ],
    types: ['bool', 'int', 'double', 'string', 'array', 'null'],
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
