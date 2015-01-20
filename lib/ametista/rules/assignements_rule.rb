require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/assignements_querier.rb'

class AssignementsRule < Rule

  extend Initializer
  initialize_with ({
    querier: AssignementsQuerier.new
  })

  def apply
    apply_on_functions_statements # << apply_on_namespaces_statements << apply_on_klasses_methods_statements
  end

  def apply_on_namespaces_statements
  end

  def apply_on_functions_statements
    Function.all.each do |function|
      parser.parse(function.contents.first.statements)
    end
  end

  def apply_on_klasses_methods_statements
  end

end
