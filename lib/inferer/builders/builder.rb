require_relative '../utilities'
require_relative '../schema'

class Builder
  extend Initializer
  initialize_with ({
    model: {
      'Stmt_Function' => Function,
      'Stmt_Class'    => Klass
    }
  })
end
