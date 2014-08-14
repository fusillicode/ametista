require_relative 'utilities'
require_relative 'a_function_ast_querier'
require_relative 'model'

class AFunctionBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    querier: AFunctionAstQuerier.new
  })

  def build ast = nil
    @ast ||= ast
    function = build_function
    function.parameters.concat(build_parameters)
    # build_assigned_variables
    # build_global_variable_definitions(procedure_raw_content)
    # current_procedure[:model]
    function
  end

  def build_function
    AFunction.find_or_create_by(
      unique_name: get_unique_name,
      name: get_name,
      statements: get_statements,
      return_statements: get_return_statements)
  end

  def build_parameters
    querier.get_parameters(ast).map do |parameter|
      parameter_name = get_parameter_name(parameter)
      AParameter.create(
        :unique_name => get_parameter_unique_name(parameter_name),
        :name => parameter_name,
        :type => 'parameter',
        :value => get_parameter_default_value(parameter),
        :i_procedure => model.send("current_#{procedure_type}"))
    end
  end

  def build_assigned_variables
    get_assignements_and_global_definitions().each do |variable|
    end
  end

  # def build_global_variable_definitions(raw_content)
  #   # Prendo tutti gli statements della funzione/metodo corrente
  #   raw_content.each do |statements|

  #     # Prendo tutti le variabili globali definite tramite global
  #     global_variables(statements).each do |global_variable|

  #       build_global_variable(global_variable)

  #     end

  #     # Prendo tutti gli assegnamenti all'interno della funzione corrente
  #     statements.xpath('./node:Expr_Assign/subNode:var').each do |assignement|

  #       # puts Model::get_LHS assignement

  #     end

  #   end
  # end

  # def global_variables(statements)
  #   statements.xpath('./node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable')
  # end

  # def global_variable_name(global_variable)
  #   global_variable.xpath('./subNode:name/scalar:string').text
  # end

  # def build_global_variable(global_variable)
  #   global_variable_name = global_variable_name(global_variable)
  #   AVariable.create(:unique_name => "#{current_procedure.unique_name}\\#{global_variable_name}",
  #                    :name => global_variable_name,
  #                    :type => 'global',
  #                    :i_procedure => current_procedure)
  # end

end
