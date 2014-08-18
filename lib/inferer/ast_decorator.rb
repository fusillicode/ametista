require_relative 'utilities'
require_relative 'xml_parser'

class ASTDecorator

  extend Initializer
  initialize_with ({
    ast: nil,
    parser: XMLParser.new,
    global_namespace_name: '\\',
    global_namespace_unique_name: '\\'
  })

  def decore ast
    @ast = is_decored?(ast) ? ast : parser.parse(ast)
    self
  end

  def is_decored? ast
    ast.instance_of? parser.output_class
  end

  # TODO implementare anche respond_to?
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      public_send method_name, *args, &block
    elsif ast.respond_to? method_name
      ast.public_send method_name, *args, &block
    else
      super
    end
  end

end
