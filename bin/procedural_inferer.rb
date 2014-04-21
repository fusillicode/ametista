xml = Nokogiri::XML redis.get './test_simple_file/1.php'

# Prendo ogni namespace
xml.xpath('.//node:Stmt_Namespace').each do |namespace|

  parent_namespace = INamespace.with(:unique_name, '\\') || INamespace.create(:unique_name => '\\', :name => '\\')

  # Costruisco ogni namespace con il suo nome e parent
  namespace.xpath('./subNode:name/node:Name/subNode:parts//scalar:string').each do |subnamespace|

    parent_namespace = INamespace.create(:unique_name => "#{parent_namespace.unique_name}\\#{subnamespace.text}",
                                         :name => subnamespace.text,
                                         :parent_i_namespace => parent_namespace)

  end

  # Prendo tutti gli statements che non siano funzioni o classi all'interno del namespace corrente
  parent_namespace.statements = IRawContent.create(
    :content => namespace.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]'),
    :i_namespace => parent_namespace)

  # Prendo tutti gli assegnamenti di variabili (senza distinzione fra globali/locali)
  namespace.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var').each do |assignement|

    # puts Model::get_LHS assignement

  end

  # Il save serve per aggiornare effettivamente l'istanza INamespace parent_namespace!
  parent_namespace.save

  # Prendo tutte le funzioni all'interno del namespace corrente
  namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Function').each do |function|

    function_name = function.xpath('./subNode:name/scalar:string').text

    current_function = IFunction.create(:unique_name => "#{parent_namespace.unique_name}\\#{function_name}",
                                        :name => function_name,
                                        :i_namespace => parent_namespace,
                                        :statements => IRawContent.create(:content => function.xpath('./subNode:stmts/scalar:array'),
                                                                          :i_function => current_function),
                                        :return_statements => IRawContent.create(:content => function.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
                                                                             :i_function => current_function))

    # Prendo tutti gli statements della funzione corrente
    function.xpath('./subNode:stmts/scalar:array').each do |statements|

      # Prendo tutti le variabili globali definite tramite global
      statements.xpath('./node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable').each do |global_variable|

        global_variable_name = global_variable.xpath('./subNode:name/scalar:string').text

        IVariable.create(:unique_name => "#{current_function.unique_name}\\#{global_variable_name}",
                         :name => global_variable_name,
                         :scope => 'global',
                         :i_function => current_function)

      end

      # Prendo tutti gli assegnamenti all'interno della funzione corrente
      statements.xpath('./node:Expr_Assign/subNode:var').each do |assignement|

        # puts Model::get_LHS assignement

      end

    end

    # Prendo tutti i parametri della funzione corrente
    function.xpath('./subNode:params/scalar:array/node:Param').each do |global_variable|

      global_variable_name = global_variable.xpath('./subNode:name/scalar:string').text

      IVariable.create(:unique_name => "#{current_function.unique_name}\\#{global_variable_name}",
                       :name => global_variable.xpath('./subNode:name/scalar:string').text,
                       :scope => 'global',
                       :value => global_variable.xpath('./subNode:default'),
                       :i_function => current_function)

    end

  end

  # Prendo tutte le classi all'interno del namespace corrente
  namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Class').each do |class_in_xml|

    current_class = IClass.create(:name => class_in_xml.xpath('./subNode:namespacedName/node:Name/subNode:parts//scalar:string')[0..-1].to_a.join('/'),
                                  :i_namespace => parent_namespace)

    # Prendo tutte le proprietà della classe corrente
    class_in_xml.xpath('./subNode:stmts/scalar:array/node:Stmt_Property').each do |one_line_property|

      one_line_property.xpath('./subNode:props/scalar:array/node:Stmt_PropertyProperty').each do |property|

        property_name = property.xpath('./subNode:name/scalar:string').text

        IVariable.create(:unique_name => "#{current_class.unique_name}\\#{property_name}",
                         :name => property.xpath('./subNode:name/scalar:string').text,
                         :value => property.xpath('./subNode:default'),
                         :i_class => current_class)

      end

    end

    # Il save serve per aggiornare effettivamente l'istanza INamespace parent_namespace!
    current_class.save

    # Prendo tutti i metodi all'interno della classe corrente
    class_in_xml.xpath('./subNode:stmts/scalar:array/node:Stmt_ClassMethod').each do |method|

      current_method = IMethod.create(:name => method.xpath('./subNode:name/scalar:string').text,
                                      :i_class => current_class,
                                      :statements => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array'),
                                                                           :i_method => current_method),
                                      :return_statements => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
                                                                           :i_method => current_method))

      # Prendo tutti gli statements del metodo corrente
      method.xpath('./subNode:stmts/scalar:array').each do |statements|

        # Prendo tutti le variabili globali definite tramite global
        statements.xpath('./node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable').each do |global_variable|

          IVariable.create(:name => global_variable.xpath('./subNode:name/scalar:string').text,
                           :scope => 'global',
                           :i_function => current_method)

        end

        # Prendo tutti gli assegnamenti all'interno del metodo corrente
        statements.xpath('./node:Expr_Assign/subNode:var').each do |assignement|

          # puts Model::get_LHS assignement

        end

      end

      # Prendo tutti i parametri del metodo corrente
      method.xpath('./subNode:params/scalar:array/node:Param').each do |parameter|

        IVariable.create(:name => parameter.xpath('./subNode:name/scalar:string').text,
                         :scope => 'global',
                         :value => parameter.xpath('./subNode:default'),
                         :i_method => current_method)

      end

      # devo prendere prima tutti gli Expr_PropertyFetch e gli Expr_ArrayDimFetch all'interno di ciascun singolo Expr_Assign.
      # ogni Expr_PropertyFetch o Expr_ArrayDimFetch ha un subNode:var e un subNode:name.
      # il subNode:var può essere a sua volta un Expr_PropertyFetch o un Expr_ArrayDimFetch mentre il subNode:name è quello che è
      # posto alla destra del Expr_PropertyFetch o del Expr_ArrayDimFetch a seconda dei casi

      # method.xpath('.//node:Expr_Assign/subNode:var').each do |lhs|
      #   p get_LHS lhs
      # end

      #   p
      #   # p lhs.xpath('.//node:Expr_ArrayDimFetch/subNode[local-name() = \'name\' or local-name() = \'dim\']/scalar[local-name() = \'string\' or local-name() = \'string\']').text
      # end

    end

  end

end

INamespace.all.to_a.each do |namespace|
  puts namespace.name + ' with parent ' + (namespace.parent_i_namespace ? namespace.parent_i_namespace.name : '')
  # p namespace.statements.content unless namespace.statements.nil?
end

# IClass.all.to_a.each do |class_in_xml|
#   puts class_in_xml.name
#   class_in_xml.properties.each do |p|
#     puts p.name
#   end
# end

IFunction.all.to_a.each do |function|
  puts function.unique_name + ' with name ' + function.name
end

# IMethod.all.to_a.each do |method|
#   puts method.name
# end

# IVariable.all.to_a.each do |local_variables|
#   puts local_variables.name
# end
