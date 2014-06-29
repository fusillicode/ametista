class INamespaceBuilder

  class << self

    def build model
      @model = model
      build_global_namespace
      build_other_namespaces
    end

    def build_global_namespace
      INamespace.create(id: '\\', :name => '\\')
      @namespace = @model.ast
      build_namespace
    end

    def build_other_namespaces
      get_namespaces.each do |namespace|
        @namespace = namespace
        build_subnamespaces
        build_namespace
      end
    end

    def build_namespace
      build_global_variables
      # build_functions
      # build_classes
    end

    def build_subnamespaces
      get_subnamespaces.each do |subnamespace|
        subnamespace_unique_name = get_subnamespace_unique_name(subnamespace)
        INamespace.create(:unique_name => '\\', :name => '\\')
        self.create(:_id => subnamespace_unique_name,
                    :name => subnamespace.text,
                    :parent_namespace => self.find(unique_name: @model.current_scope).first,
                    :statements => get_statements)
      end
    end

    def build_global_variables
        get_assignements.each do |global_variable|
          p get_variable_name(global_variable)
        end
        # get_global_variables.each do |global_variable|
        # global_variable_name = get_variable_name(get_global_variable_value)
        # IVariable.create(:unique_name => global_variable_name,
        #                  :name => global_variable_name,
        #                  :type => 'global',
        #                  :value => get_global_variable_value(get_global_variable_value),
        #                  :i_procedure => @model.send("current_#{@procedure_type}"))
        # end
    end

    # le variabili assegnate
    def get_assignements
      @namespace.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var')
    end

    def get_global_variable_value(global_variable)
      global_variable.xpath('./subNode:expr')
    end

    def get_variable_name(node)

      node = node.xpath('./*[1]')[0]

      case node.name
      when 'Expr_Variable'
        name = node.xpath('./subNode:name/scalar:string').text
        # non tratto le variabili di variabli (e.g. $$v)
        return false if name.nil? or name.empty?
        # le variabili plain assegnate sono comunque in GLOBALS
        return "GLOBALS[#{name}]" if name != 'GLOBALS'
        name
      when 'Expr_PropertyFetch'
        # non tratto proprietà con nomi dinamici
        return false if !var = get_variable_name(node.xpath('./subNode:var'))
        return false if !name = get_variable_name(node.xpath('./subNode:name'))
        var << '->' << name
      when 'Expr_ArrayDimFetch'
        # non tratto indici di array dinamici
        return var if !var = get_variable_name(node.xpath('./subNode:var'))
        dim = node.xpath('./subNode:dim/*[name() = "node:Scalar_String" or name() = "node:Scalar_LNumber"]/subNode:value/*').text
        return false if dim.nil? or dim.empty?
        var << '[' << dim << ']'
      when 'string'
        node.text
      else
        false
      end

    end

    def build_functions
      get_functions.each do |function|
        IFunctionBuilder.build(@model)
      end
    end

    def build_classes
      get_classes.each do |a_class|
        IClassBuilder.build(@model)
      end
    end

    def get_namespaces
      @model.ast.xpath('.//node:Stmt_Namespace')
    end

    def get_subnamespaces
      @namespace.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    end

    def get_subnamespace_unique_name(subnamespace)
      "#{@model.current_scope}\\#{subnamespace.text}"
    end

    def get_statements
      @namespace.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
    end

    def get_functions
      @namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
    end

    def get_classes
      @namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Class')
    end

  end

end

