# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative 'methods_calls_rule'

class InferenceEngine

  extend Initializer
  initialize_with ({
    rules: {
      methods_calls_rule: MethodsCallsRule.new
    }
  })

  def infer
    rules.each do |key, rule|
      rule.apply
    end
  end
end
