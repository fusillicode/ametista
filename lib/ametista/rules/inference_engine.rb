# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative 'methods_calls_rule'

class InferenceEngine

  extend Initializer
  initialize_with ({
    rules: {
      primitive_types_assignements: PrimitiveTypesAssignements.new
    },
    model_modified: true,
    total_iterations: 7,
    current_iteration: 1
  })

  alias_method :model_modified?, :model_modified

  def infer
    iterate_on_rules while continue?
  end

  def continue?
    model_modified? and current_iteration <= total_iterations
  end

  def iterate_on_rules
    @current_iteration += 1
    model_modified = result_of_rules_application
  end

  def result_of_rules_application
    apply_rules.reduce :&
  end

  def apply_rules
    rules.map do |key, rule|
      rule.apply
    end
  end

end
