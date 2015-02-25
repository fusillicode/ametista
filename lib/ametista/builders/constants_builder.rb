require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/constants_querier'

class ConstantsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: ConstantsQuerier.new
  })

  def build ast
    @ast = ast
    constants
  end

  def constants
    defined_constants | klass_constants
  end

  def defined_constants
    querier.defined_constants(ast).map_unique('id') do |defined_constant_ast|
      Constant.find_or_create_by(
        name: querier.defined_constant_name(defined_constant_ast),
      )#.tap { |o| version_builder.defined_constant_version(o, defined_constant_ast) }
    end
  end

  def klass_constants
    []
  end

  def defined_constant_version variable, ast
    rhs = querier.defined_constant_rhs(ast)
    Version.create(
      variable: variable,
      position: querier.position(ast),
      # TODO rimuovere il check sul rhs quando Postgres consentirà l'inserimento
      # di stringhe vuote per il campo xml
      rhs: (rhs.empty? ? ' ' : rhs)
    )
  end

end
