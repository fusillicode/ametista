require_relative '../utilities'
require_relative '../schema'

class Builder
  extend Initializer
  initialize_with ({
    model: {
      'node:Stmt_Function' => Function,
      'node:Stmt_Class'    => Klass
    }
  })
end
