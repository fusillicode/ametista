require_relative 'utilities'
require_relative 'php_language'

class EntityMapper
  extend Initializer
  initialize_with ({
    language: PHPLanguage.new,
    map: {
      'node:Stmt_Function' => Function,
      'node:Stmt_Class'    => Klass
    }
  })
end
