require_relative '../utilities'

class Querier
  extend Initializer
  initialize_with ({
    ast_decorator: ASTDecorator.new,
  })

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    else
      ast_decorator.public_send method_name, *args, &block
    end
  end
end
