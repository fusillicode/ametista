require_relative '../utilities'
require_relative '../ast_decorator'

class Querier
  extend Initializer
  initialize_with ({
    ast_decorator: ASTDecorator.new,
  })

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif ast_decorator.respond_to? method_name
      ast_decorator.public_send method_name, *args, &block
    else
      super
    end
  end
end
