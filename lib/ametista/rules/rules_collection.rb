require_relative 'rule'

class RulesCollection < Rule

  attribute :override_rules, Axiom::Types::Boolean, default: false
  attribute :rules, Hash, default: {}

  def initialize args = {}, &block
    super
    add_rules ({
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
        })
    self.default = args[:default_rule] || Rule.new
  end

  def apply *args
    @rules.map { |name, rule| rule.apply *args }.flatten
  end

  def apply_rule name, *args
    @rules[name].apply *args
  end

  def add_rules rules = {}
    rules.map do |key, rule|
      add_rule key, rule
    end
  end

  def add_rule key = nil, rule = {}, &block
    key = key || rule[:name]
    check_rule_override key
    name = rule[:name] rescue key
    logic = rule[:logic] rescue rule
    @rules[key] = rule.is_a?(Rule) ? rule : Rule.new(name: name, logic: logic, &block)
  end

  def check_rule_override key
    raise "There is already a rule identified by the key '#{key}'" if not(override_rules) && @rules.has_key?(key)
  end

  def []= key, value
    add_rule key: key, value: value
  end

  def remove_rule name
    @rules.delete_key name
  end

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    else
      @rules.public_send method_name, *args, &block
    end
  end

end
