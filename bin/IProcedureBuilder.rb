class IProcedureBuilder

  class << self

    def build model
      @model = model
      build_procedure
      build_parameters
      build_assigned_variables
      # build_global_variable_definitions(procedure_raw_content)
      @current_procedure[:model]
    end

    def build_procedure
      @current_procedure[:model] = IProcedure.create(unique_name: get_unique_name,
                                                     name: get_name,
                                                     type: @procedure_type,
                                                     statements: get_statements,
                                                     return_statements: get_return_statements))
    end

    def build_parameters
      get_parameters.each do |parameter|

        parameter_name = get_parameter_name(parameter)

        IVariable.create(:unique_name => get_parameter_unique_name(parameter_name),
                         :name => parameter_name,
                         :type => 'parameter',
                         :value => get_parameter_default_value(parameter),
                         :i_procedure => @model.send("current_#{@procedure_type}"))

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
    #   IVariable.create(:unique_name => "#{current_procedure.unique_name}\\#{global_variable_name}",
    #                    :name => global_variable_name,
    #                    :type => 'global',
    #                    :i_procedure => current_procedure)
    # end


    def get_name
      @procedure.xpath('./subNode:name/scalar:string').text
    end

    def get_unique_name
      '\\\\' << @procedure.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    end

    def get_return_statements
      @procedure.xpath('./subNode:stmts/scalar:array/node:Stmt_Return')
    end

    def get_statements
      @procedure.xpath('./subNode:stmts/scalar:array')
    end

    def get_parameters
      @procedure.xpath('./subNode:params/scalar:array/node:Param')
    end

    def get_parameter_name(parameter)
      parameter.xpath('./subNode:name/scalar:string').text
    end

    def get_parameter_unique_name(parameter_name)
      @model.send("current_#{@procedure_type}").unique_name << "\\#{parameter_name}"
    end

    def get_parameter_default_value(parameter)
      parameter.xpath('./subNode:default')
    end

    def get_assignements_and_global_definitions
      @procedure.xpath('./subNode:stmts/scalar:array/*[name() = "node:Expr_Assign" or name() = "node:Stmt_Global"]')
    end

  end

end
