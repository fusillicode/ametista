# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative 'methods_calls_rule'

class InferenceEngine

  extend Initializer
  initialize_with ({
    rules: {
      methods_calls_rule: MethodsCallsRule.new
    },
    model_modified: false,
    total_iterations: 7,
    current_iteration: 1
  })

  alias_method :model_modified?, :model_modified

  def infer
    apply_rules while continue?
  end

  def continue?
    model_modified? and current_iteration <= total_iterations
  end

  def apply_rules
    current_iteration += 1
    model_modified = rules_application_result
  end

  def rules_application_result
    rules_application.reduce :&
  end

  def rules_application
    rules.map do |key, rule|
      rule.apply
    end
  end

end
