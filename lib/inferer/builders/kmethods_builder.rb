require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/kmethods_ast_querier'


class KMethodsBuilder

  extend Initializer
  initialize_with ({
    querier: KMethodsAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    kmethods
  end

  def kmethods
    querier.kmethods.each do |kmethod_ast|
      KMethod.find_or_create_by(
        unique_name: querier.unique_name(kmethod_ast),
        name: querier.name(kmethod_ast)
      )
    end
  end

end

