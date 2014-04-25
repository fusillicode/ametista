require "ohm"
require_relative "./Unique"
require_relative "./IRawContent"
require_relative "./IVariable"

class IMethod < Ohm::Model

  extend Unique
  unique :unique_name
  attribute :unique_name

  index :name
  attribute :name

  reference :statements, :IRawContent
  reference :return_statements, :IRawContent

  collection :parameters, :IVariable, :i_method
  collection :local_variables, :IVariable, :i_method

  reference :i_class, :IClass

  class << self

    attr_accessor :method
    attr_accessor :model

    def build(method, model)
      self.method = method
      self.model = model
      build_method
      # build_parameters
      # build_global_variable_definitions(procedure_raw_content)
    end

    # model.current_i_method = IMethod.create(:name => method.xpath('./subNode:name/scalar:string').text,
    #                                 :i_class => current_class,
    #                                 :statements => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array'),
    #                                                                      :i_method => current_method),
    #                                 :return_statements => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
    #                                                                      :i_method => current_method))

    # # Prendo tutti gli statements del metodo corrente
    # method.xpath('./subNode:stmts/scalar:array').each do |statements|

    #   # Prendo tutti le variabili globali definite tramite global
    #   statements.xpath('./node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable').each do |global_variable|

    #     IVariable.create(:name => global_variable.xpath('./subNode:name/scalar:string').text,
    #                      :type => 'global',
    #                      :i_method => current_method)

    #   end

    #   # Prendo tutti gli assegnamenti all'interno del metodo corrente
    #   statements.xpath('./node:Expr_Assign/subNode:var').each do |assignement|

    #     # puts Model::get_LHS assignement

    #   end

    # end

    # # Prendo tutti i parametri del metodo corrente
    # method.xpath('./subNode:params/scalar:array/node:Param').each do |parameter|

    #   IVariable.create(:name => parameter.xpath('./subNode:name/scalar:string').text,
    #                    :type => 'global',
    #                    :value => parameter.xpath('./subNode:default'),
    #                    :i_method => current_method)

    # end

    def build_method
      model.current_i_method = self.create(:unique_name => get_unique_name,
                                             :name => get_name,
                                             :i_class => model.current_i_class,
                                             :statements => IRawContent.create(:content => get_raw_content,
                                                                               :i_method => model.current_i_method),
                                             :return_statements => IRawContent.create(:content => get_return_statements,
                                                                                      :i_method => model.current_i_method))
    end

    def get_name
      method.xpath('./subNode:name/scalar:string').text
    end

    def get_unique_name
      '\\\\' + method.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    end

    def get_return_statements
      method.xpath('./subNode:stmts/scalar:array/node:Stmt_Return')
    end

    def get_raw_content
      method.xpath('./subNode:stmts/scalar:array')
    end

    def build_parameters
      get_parameters.each do |parameter|

        parameter_name = get_parameter_name(parameter)

        IVariable.create(:unique_name => get_parameter_unique_name(parameter_name),
                         :name => parameter_name,
                         :type => 'global',
                         :value => get_parameter_default_value(parameter),
                         :i_method => model.current_i_method)

      end
    end

    def get_parameters
      method.xpath('./subNode:params/scalar:array/node:Param')
    end

    def get_parameter_unique_name(parameter_name)
      "#{model.current_i_method.unique_name}\\#{parameter_name}"
    end

    def get_parameter_name(parameter)
      parameter.xpath('./subNode:name/scalar:string').text
    end

    def get_parameter_default_value(parameter)
      parameter.xpath('./subNode:default')
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
    #   IVariable.create(:unique_name => "#{current_method.unique_name}\\#{global_variable_name}",
    #                    :name => global_variable_name,
    #                    :type => 'global',
    #                    :i_method => current_method)
    # end

  end

end
