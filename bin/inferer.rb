#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"
require "ohm/contrib"

class INamespace < Ohm::Model
  index :name
  attribute :name
  # I namespace hanno nome univoco ed è quello completo di tutta la loro gerarchia
  # questo perchè sono le entità a livello maggiore
  unique :name

  reference :parent_inamespace, :INamespace
  reference :statements, :IRawContent

  collection :i_classes, :IClass, :i_namespace
  collection :i_functions, :IFunction, :i_namespace
end

class IClass < Ohm::Model
  index :name
  attribute :name

  reference :i_namespace, :INamespace

  collection :i_methods, :IMethod, :i_class
  collection :properties, :IProperty, :i_class
end

class IProperty < Ohm::Model
  index :name
  attribute :name

  reference :i_class, :IClass
end

class IMethod < Ohm::Model
  index :name
  attribute :name

  reference :i_class, :IClass
  reference :statements, :IRawContent
  reference :return_values, :IRawContent

  collection :parameters, :IVariable, :i_method
  collection :local_variables, :IVariable, :i_method
end

class IFunction < Ohm::Model
  index :name
  attribute :name

  reference :i_namespace, :INamespace
  reference :statements, :IRawContent
  reference :return_values, :IRawContent

  collection :parameters, :IVariable, :i_function
  collection :local_variables, :IVariable, :i_function
end

class IRawContent < Ohm::Model
  attribute :content

  reference :i_namespace, :INamespace
  reference :i_method, :IMethod
  reference :i_function, :IFunction
end

class IVariable < Ohm::Model
  index :name
  attribute :name
  attribute :value
  attribute :type

  reference :i_namespace, :INamespace
  reference :i_method, :IMethod
  reference :i_function, :IFunction

  def local?
    self.method or self.function or self.namespace.name === '\\'
  end

  def global?
    not self.local?
  end

end

class IParser

  @scalar_types = ['bool', 'int', 'double', 'string', 'array', 'null']

  @magic_constants = ['Scalar_LineConst',
                     'Scalar_FileConst',
                     'Scalar_DirConst',
                     'Scalar_FuncConst',
                     'Scalar_ClassConst',
                     'Scalar_TraitConst',
                     'Scalar_MethodConst',
                     'Scalar_NSConst']

  def self.get_parameter_type parameter

    # L'ultimo elemento del nome esteso del parametro che può essere eventualmente il type hint per il parametro
    type_hint = parameter.xpath('./subNode:type//subNode:parts//scalar:string').last

    # type_hint può essere Nil
    return type_hint.text if type_hint and @scalar_types.include? type_hint.text

    default_value = parameter.xpath('./subNode:default/*[1]').first.name

    # 1.2 -> node:Scalar_DNumber
    if default_value === 'Scalar_DNumber'
      'double'
    # 1 -> node:Scalar_LNumber
    elsif default_value === 'Scalar_LNumber'
      'int'
    # true, false, null -> node:Expr_ConstFetch
    elsif default_value === 'Expr_ConstFetch'
      'bool'
    # array() -> node:Expr_Array
    elsif default_value === 'Expr_Array'
      'array'
    # 'asd' -> node:Scalar_String or __FILE__ -> node:Scalar_FileConst
    elsif default_value === 'Scalar_String' or @magic_constants.include? default_value
      'string'
    else
      '✘'
    end

  end

  def self.get_LHS node

    node = node.xpath('./*[1]')[0]

    case node.name
    when 'Expr_Variable'
      node.xpath('./subNode:name/scalar:string').text
    when 'Expr_PropertyFetch'
      self.get_LHS(node.xpath('./subNode:var')) + '->' + self.get_LHS(node.xpath('./subNode:name'))
    when 'Expr_ArrayDimFetch'
      self.get_LHS(node.xpath('./subNode:var')) + '[' + node.xpath('./subNode:dim//subNode:value/*').text + ']'
    # sia self:: che AClass::
    when 'Expr_StaticPropertyFetch'
      node.xpath('./subNode:class//subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('/') + '::' + node.xpath('./subNode:name/scalar:string')[0].text
    when 'Expr_Assign'
      self.get_LHS node.xpath('./subNode:var')
    when 'Expr_Concat'
      self.get_LHS(node.xpath('./subNode:left')) + '.' + self.get_LHS(node.xpath('./subNode:right'))
    when 'Scalar_String'
      node.xpath('./subNode:value/*').text
    when 'string'
      node.text
    else
      '✘'
    end

  end

end


get = { :namespaces => './/node:Stmt_Namespace',
        :subnamespaces => './subNode:name/node:Name/subNode:parts//scalar:string',
        :namespace_statements => './subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]',
        :functions => './subNode:stmts/scalar:array/node:Stmt_Function',
        :function_name => './subNode:name/scalar:string',
        :function_statement => './subNode:stmts/scalar:array',
        :function_parameters => './subNode:params//node:Param',
        :parameter_name => './subNode:name/scalar:string',
        :classes => './subNode:stmts/scalar:array/node:Stmt_Class',
        :class_name => './subNode:namespacedName/node:Name/subNode:parts//scalar:string',
        :class_methods => './subNode:stmts/scalar:array/node:Stmt_ClassMethod',
        :method_name => './subNode:name/scalar:string' }

redis = Redis.new

xml = Nokogiri::XML redis.get './test_simple_file/1.php'

# Prendo ogni namespace
xml.xpath('.//node:Stmt_Namespace').each do |namespace|

  parent_namespace = INamespace.with(:name, '\\') || INamespace.create(:name => '\\')

  # Costruisco ogni namespace con il suo nome e parent
  namespace.xpath('./subNode:name/node:Name/subNode:parts//scalar:string').each do |subnamespace|

    current_namespace_name = "#{parent_namespace.name}\\#{subnamespace.text}"

    if current_namespace = INamespace.with(:name, current_namespace_name)

      current_namespace.parent_namespace = parent_namespace
      parent_namespace = current_namespace

    else

      parent_namespace = INamespace.create(:name              => current_namespace_name,
                                           :parent_inamespace => parent_namespace)

    end

  end

  # Prendo tutti gli statements che non siano funzioni o classi all'interno del namespace corrente
  parent_namespace.statements = IRawContent.create(
    :content    => namespace.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]'),
    :i_namespace => parent_namespace)

  namespace.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var').each do |assignement|

    puts IParser::get_LHS assignement

  end

  # Il save serve per aggiornare effettivamente l'istanza INamespace parent_namespace!
  parent_namespace.save

  # Prendo tutte le funzioni all'interno del namespace corrente
  namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Function').each do |function|

    current_function = IFunction.create(:name          => function.xpath('./subNode:name/scalar:string').text,
                                        :i_namespace    => parent_namespace,
                                        :statements    => IRawContent.create(:content   => function.xpath('./subNode:stmts/scalar:array'),
                                                                             :i_function => current_function),
                                        :return_values => IRawContent.create(:content   => function.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
                                                                             :i_function => current_function))

    # Prendo tutti gli assegnamenti all'interno della funzione corrente
    function.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var').each do |assignement|

      puts IParser::get_LHS assignement

    end

    # Prendo tutti i parametri della funzione corrente
    function.xpath('./subNode:params/scalar:array/node:Param').each do |parameter|

      IVariable.create(:name      => parameter.xpath('./subNode:name/scalar:string').text,
                       :type      => IParser::get_parameter_type(parameter),
                       :value     => parameter.xpath('./subNode:default'),
                       :i_function => current_function)

    end

  end

  # Prendo tutte le classi all'interno del namespace corrente
  namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Class').each do |class_in_xml|

    current_class = IClass.create(:name       => class_in_xml.xpath('./subNode:namespacedName/node:Name/subNode:parts//scalar:string')[0..-1].to_a.join('/'),
                                  :i_namespace => parent_namespace)

    # Prendo tutti i metodi all'interno della classe corrente
    class_in_xml.xpath('./subNode:stmts/scalar:array/node:Stmt_ClassMethod').each do |method|

      current_method = IMethod.create(:name          => method.xpath('./subNode:name/scalar:string').text,
                                      :i_class        => current_class,
                                      :statements    => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array'),
                                                                           :i_method => current_method),
                                      :return_values => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
                                                                           :i_method => current_method))

      # Prendo tutti gli assegnamenti all'interno del metodo corrente
      method.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var').each do |assignement|

        puts IParser::get_LHS assignement

      end

      # Prendo tutti i parametri del metodo corrente
      method.xpath('./subNode:params/scalar:array/node:Param').each do |parameter|

        IVariable.create(:name    => parameter.xpath('./subNode:name/scalar:string').text,
                         :type    => IParser::get_parameter_type(parameter),
                         :value   => parameter.xpath('./subNode:default'),
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

# IClass.all.to_a.each do |class_in_xml|
#   puts class_in_xml.name
# end

# IMethod.all.to_a.each do |method|
#   puts method.name
# end

# IVariable.all.to_a.each do |local_variables|
#   puts local_variables.name
# end

# INamespace.all.to_a.each do |namespace|
#   puts namespace.name + ' with parent ' + (namespace.parent_namespace ? namespace.parent_namespace.name : '')
#   p namespace.statements.content unless namespace.statements.nil?
# end

