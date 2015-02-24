require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/assignements_querier.rb'

class VariablesUsesRule < Rule

  extend Initializer
  initialize_with ({
    querier: AssignementsQuerier.new
  })

  def apply
    GlobalVariable.all.each do |variable|
      ap variable.unique_name
      variable.versions.all.map do |version|
        ap version.rhs
        ap type parser.parse(version.rhs)
      end
    end
  end

  def type rhs
    bho = {
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
      'Expr_Closure'                 => 'function',
      'Expr_Cast_Array'              => 'array',
      'Expr_Cast_Bool'               => 'bool',
      'Expr_Cast_Double'             => 'float',
      'Expr_Cast_Int'                => 'int',
      'Expr_Cast_Object'             => 'object',
      'Expr_Cast_String'             => 'string',
      'Expr_Cast_Unset'              => 'null',
      'Expr_InstanceOf'              => 'bool',
      'Scalar_DNumber'               => 'float',
      'Scalar_LNumber'               => 'int'
    }
    expression_type = rhs.xpath('name(./*[1])')
    ap expression_type
    type = bho[expression_type]
    return type if type

    case expression_type
    when 'Expr_ConstFetch'
      const_name = rhs.xpath('./Expr_ConstFetch/name/Name/parts/array/string').text
    when 'Expr_New'
      rhs.xpath('./class/Name_FullyQualified/parts/array/string').to_a.join(querier.namespace_separator)
    when 'Expr_BinaryOp_Plus'

    when 'Expr_Unary_Plus', 'Expr_Unary_Minus'

    when 'Expr_BinaryOp_Minus', 'Expr_BinaryOp_Mul'

    when 'Expr_BinaryOp_Div'

    when 'Expr_BinaryOp_Mod'

    when 'Expr_BinaryOp_Minus', 'Expr_BinaryOp_Mul'

    when 'Expr_BinaryOp_BitwiseAnd', 'Expr_BinaryOp_BitwiseOr', 'Expr_BinaryOp_BitwiseXor'

    when 'Expr_BitwiseNot'

    when 'Expr_ErrorSuppress'

    end
    # return expression_type if Global.lang.php.primitive_types.include? expression_type
  end

end
