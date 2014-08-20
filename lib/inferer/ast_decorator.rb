require_relative 'utilities'

class ASTDecorator

  extend Initializer
  initialize_with ({
    language: PHPLanguage.new,
    ast: nil,
    global_namespace_name: '\\',
    global_namespace_unique_name: '\\'
  })

  # TODO implementare anche respond_to?
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      public_send method_name, *args, &block
    elsif ast.respond_to? method_name
      ast.public_send method_name, *args, &block
    elsif language.respond_to? method_name
      language.public_send method_name, *args, &block
    else
      super
    end
  end

end
