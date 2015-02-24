require_relative '../xml_parser'
require 'virtus'

# una regola la posso costruire con :
# - un blocco => apply chiama il blocco
# - una proc => apply chiama la proc
# - una lambda => apply chiama la lambda
# - un oggetto Proc => apply chiama la Proc
# - un oggetto qualisiasi => apply chiama to_proc e poi l'oggetto
# - un'altra regola => apply chiama l'apply della regola

class Rule

  include Virtus.model
  attribute :name, String
  attribute :parser, XmlParser, default: XmlParser.new
  attribute :querier, Querier, default: Querier.new
  attribute :logic

  # args può essere una proc, una lamda, un hash come quello di initialize_with e un qualunque oggetto
  def initialize args = {}, &block
    super
    @logic = args[:logic] || block || args
  end

  def apply *args
    @logic || @logic.call(*args)
  end

  def call *args
    apply *args
  end

end
