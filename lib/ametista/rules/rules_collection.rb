require 'virtus'
require_relative 'rule'

class RulesCollection < Rule

  include Virtus.model
  attribute :rules, Hash, default: {
    'Expr_AssignOp_ShiftLeft'      => 'int',
    'Expr_AssignOp_ShiftRight'     => 'int',
    'Expr_Array'                   => 'array',
    'Expr_BinaryOp_BooleanAnd'     => 'bool',
    'Expr_BinaryOp_BooleanOr'      => 'bool',
    'Expr_BinaryOp_Concat'         => 'string',
    'Expr_BinaryOp_Equal'          => 'bool',
    'Expr_BinaryOp_Greater'        => 'bool',
    'Expr_BinaryOp_GreaterOrEqual' => 'bool',
    'Expr_BinaryOp_Identical'      => 'bool',
    'Expr_BinaryOp_LogicalAnd'     => 'bool',
    'Expr_BinaryOp_LogicalOr'      => 'bool',
    'Expr_BinaryOp_LogicalXor'     => 'bool',
    'Expr_BinaryOp_NotIdentical'   => 'bool',
    'Expr_BinaryOp_Smaller'        => 'bool',
    'Expr_BinaryOp_SmallerOrEqual' => 'bool',
    'Expr_BinaryOp_ShiftLeft'      => 'int',
    'Expr_BinaryOp_ShiftRight'     => 'int',
    'Expr_Closure'                 => 'callback',
    'Expr_Cast_Array'              => 'array',
    'Expr_Cast_Bool'               => 'bool',
    'Expr_Cast_Double'             => 'float',
    'Expr_Cast_Int'                => 'int',
    'Expr_Cast_Object'             => 'object',
    'Expr_Cast_String'             => 'string',
    'Expr_Cast_Unset'              => 'NULL',
    'Expr_InstanceOf'              => 'bool',
    'Scalar_DNumber'               => 'float',
    'Scalar_LNumber'               => 'int'
  }
  attribute :default_rule, Rule, default: Rule.new

  def initialize args = {}
    super args
    init_rules
  end

  def init_rules
    @rules = rules.each_with_object({}) do |(rule_name, logic), hash|
      hash[rule_name] = Rule.new(name: rule_name, logic: logic)
    end
    @rules.default = default_rule
  end

  def apply *args
    @rules.map do |rule|
      rule.apply *args
    end
  end

  def apply_rule rule_name, args
    @rules[rule_name].apply args
  end

end
