require_relative '../schema'
require_relative '../queriers/assignements_querier'
require_relative 'rule'
require_relative 'rules_collection'

class GlobalVariablesAssignementsRule < Rule

  extend Initializer
  initialize_with ({
    querier: AssignementsQuerier.new,
  })

  def apply
    GlobalVariable.all.each do |global_variable|
      variable.versions.all.map do |version|
        ap rules_collection[expression_type].apply
      end
    end
  end

  # def infer rhs

  #   ap expression_type
  #   type = immediate_rules[expression_type]
  #   return type if type

  #   case expression_type
  #   when 'Expr_ConstFetch'
  #     const_name = rhs.xpath('./Expr_ConstFetch/name/Name/parts/array/string').text
  #   when 'Expr_New'
  #     rhs.xpath('./class/Name_FullyQualified/parts/array/string').to_a.join(querier.namespace_separator)
  #   when 'Expr_BinaryOp_Plus'

  #   when 'Expr_Unary_Plus', 'Expr_Unary_Minus'

  #   when 'Expr_BinaryOp_Minus', 'Expr_BinaryOp_Mul'

  #   when 'Expr_BinaryOp_Div'

  #   when 'Expr_BinaryOp_Mod'

  #   when 'Expr_BinaryOp_Minus', 'Expr_BinaryOp_Mul'

  #   when 'Expr_BinaryOp_BitwiseAnd', 'Expr_BinaryOp_BitwiseOr', 'Expr_BinaryOp_BitwiseXor'

  #   when 'Expr_BitwiseNot'

  #   when 'Expr_ErrorSuppress'

  #   end
  #   # return expression_type if Global.lang.php.primitive_types.include? expression_type
  # end

end
