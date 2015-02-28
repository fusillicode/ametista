require_relative '../xml_parser'
require_relative '../queriers/querier'
require 'virtus'

=begin

una regola la posso costruire con :

  a = Rule.new({logic: { |asd| 'ciao' }})
  a.apply # chiama il blocco, block.call

  a = Rule.new({logic: Proc.new { 'ciao' }})
  a.apply # chiama la proc o l'oggetto callable => obj.call

  a = Rule.new({logic: Object.new})
  a.apply # Object non è callable ritorna l'oggetto stesso

  a = Rule.new({logic: Rule.new})
  a.apply # chiama l'apply della regola

  a = Rule.new
  a.apply # ritorna la regola

  # le regole possono o meno scrivere sul modello quando vengono applicate
  # o meglio ci sono regole che scrivono sul modello ed altre che non scrivono

=end

class Rule

  include Virtus.model
  attribute :name, String, default: self.name
  attribute :parser, XmlParser, default: XmlParser.new
  attribute :querier, Querier, default: Querier.new
  attribute :logic

  def initialize args = {}, &block
    super
    @logic = args[:logic] || block
  end

  def apply *args
    @logic.respond_to?(:call) ? @logic.call(*args) : @logic
  end

  def call *args
    apply *args
  end

end

class RuleApplicationResult

  include Virtus.model
  attribute :model_modified, Axiom::Types::Boolean, default: true

end
