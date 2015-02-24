# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative 'global_variables_assignements_rule'
require_relative 'global_variables_uses_rule'
require 'virtus'

class InferenceEngine

  include Virtus.model
  attribute :rules, Hash, default: {
    global_variables_assignements_rule: GlobalVariablesAssignementsRule.new,
    global_variables_uses_rule: GlobalVariablesUsesRule.new
  }
  attribute :model_modified, Axiom::Types::Boolean, default: true
  attribute :total_iterations, Integer, default: 7
  attribute :current_iteration, Integer, default: 1

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
