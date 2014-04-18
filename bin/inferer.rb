#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"

module Unique
  def create atts = {}
    begin
      super
    rescue Ohm::UniqueIndexViolation => e
      self.with :unique_name, atts[:unique_name]
    end
  end
end

class INamespace < Ohm::Model

  extend Unique
  index :unique_name
  attribute :unique_name
  unique :unique_name

  index :name
  attribute :name

  reference :parent_i_namespace, :INamespace
  reference :statements, :IRawContent

  collection :i_classes, :IClass, :i_namespace
  collection :i_functions, :IProcedure, :i_namespace

end

class IClass < Ohm::Model

  extend Unique
  index :unique_name
  attribute :unique_name
  unique :unique_name

  index :name
  attribute :name

  reference :i_namespace, :INamespace

  collection :i_methods, :IProcedure, :i_class
  collection :properties, :IVariable, :i_class

end

class IProcedure < Ohm::Model

  extend Unique
  index :unique_name
  attribute :unique_name
  unique :unique_name

  index :name
  attribute :name

  # function, method
  index :type
  attribute :type

  # method
  reference :i_class, :IClass
  # function
  reference :i_namespace, :INamespace

  reference :statements, :IRawContent
  reference :return_values, :IRawContent

  collection :parameters, :IVariable, :i_procedure
  collection :local_variables, :IVariable, :i_procedure

end

class IRawContent < Ohm::Model

  attribute :content

  reference :i_namespace, :INamespace
  reference :i_method, :IProcedure
  reference :i_function, :IProcedure

end

class IVariable < Ohm::Model

  extend Unique
  index :unique_name
  attribute :unique_name
  unique :unique_name

  index :name
  attribute :name

  # local, global, property
  index :scope
  attribute :scope

  attribute :value

  set :types, :IType

  # local, global
  reference :i_namespace, :INamespace
  # property
  reference :i_class, :IClass
  # local, global
  reference :i_method, :IProcedure
  # local, global
  reference :i_function, :IProcedure

  def local?
    scope == 'local'
  end

  def global?
    scope == 'global'
  end

  def property?
    scope == 'property'
  end

end

class IType < Ohm::Model
  extend Unique
  index :name
  attribute :name
end

class ModelBuilder

  def initialize
    build_types
    @magic_constants = ['Scalar_LineConst', 'Scalar_FileConst',
                        'Scalar_DirConst', 'Scalar_FuncConst',
                        'Scalar_ClassConst', 'Scalar_TraitConst',
                        'Scalar_MethodConst', 'Scalar_NSConst']
    @global_variables = ['GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER',
                         'FILES', '_SESSION', '_ENV', '_COOKIE']
    @redis = Redis.new
  end

  def build_types
    ['bool', 'int', 'double', 'string', 'array', 'null'].each do |type|
      IType.create(:name => type)
    end
  end

  def build
    while parse(asts)
      build_namespaces
    end
  end

  def parse(ast)
    @current_ast = Nokogiri::XML(ast) unless last_ast?(ast)
  end

  def asts
    @redis.brpoplpush('xmls_asts', 'done', :timeout => 0)
  end

  def last_ast?(ast)
    ast == "THAT'S ALL FOLKS!"
  end

  # NAMESPACE ##################################################################

  def build_namespaces
    namespaces.each do |namespace|
      set_global_namespace
      build_namespace(namespace)
      build_functions(namespace)
    end
  end

  def namespaces
    @current_ast.xpath('.//node:Stmt_Namespace')
  end

  def set_global_namespace
    @current_i_namespace = INamespace.with(:unique_name, '\\') ||
                           INamespace.create(:unique_name => '\\', :name => '\\')
  end

  def build_namespace(namespace)
    build_namespace_hierarchy(namespace)
    build_namespace_assignements(namespace)
    build_namespace_raw_content(namespace)
  end

  # Costruisco ogni namespace con il suo nome e parent
  def build_namespace_hierarchy(namespace)
    namespace_hierarchy(namespace).each do |subnamespace|
      @current_i_namespace = INamespace.create(:unique_name => "#{@current_i_namespace.unique_name}\\#{subnamespace.text}",
                                               :name => subnamespace.text,
                                               :parent_i_namespace => @current_i_namespace)
    end
  end

  def namespace_hierarchy(namespace)
    namespace.xpath('./subNode:name/node:Name/subNode:parts//scalar:string')
  end

  def build_namespace_assignements(namespace)
    # Prendo tutti gli assegnamenti di variabili (senza distinzione fra globali/locali)
    namespace_assignements(namespace).each do |assignement|
      # puts ModelBuilder::get_LHS assignement
    end
  end

  def namespace_assignements(namespace)
    namespace.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var')
  end

  def build_namespace_raw_content(namespace)
    # Prendo tutti gli statements che non siano funzioni o classi all'interno del namespace corrente
    @current_i_namespace.statements = IRawContent.create(:content => namespace_raw_content(namespace),
                                                         :i_namespace => @current_i_namespace)
    # Il save serve per aggiornare effettivamente l'istanza INamespace @current_i_namespace!
    @current_i_namespace.save
  end

  def namespace_raw_content(namespace)
    namespace.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end


  # FUNZIONI ###################################################################

  def build_functions(namespace)
    # Prendo tutte le funzioni all'interno del namespace corrente
    functions(namespace).each do |function|
      procedure_raw_content = procedure_raw_content(function)
      build_procedure(function, 'function', procedure_raw_content)
      # build_global_variable_definitions(procedure_raw_content)
      build_parameters(function, 'function')
    end
  end

  def functions(namespace)
    namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
  end

  def procedure_raw_content(procedure)
    procedure.xpath('./subNode:stmts/scalar:array')
  end

  def build_procedure(procedure, type, raw_content)
    procedure_name = procedure_name(procedure)
    if type == 'function'
      unique_name = "#{@current_i_namespace.unique_name}\\#{procedure_name}"
      scope = :i_namespace
      type = :i_function
      scope_entity = @current_i_namespace
    elsif type == 'method'
      unique_name = "#{@curret_i_class.unique_name}\\#{procedure_name}"
      scope = :i_class
      type = :i_method
      scope_entity = @current_i_class
    else
      'RAISE EXCEPTION!!!'
    end
    @current_i_procedure = IProcedure.create(:unique_name => unique_name,
                                             :name => procedure_name,
                                             scope => scope_entity,
                                             :statements => IRawContent.create(:content => procedure_raw_content(procedure),
                                                                               type => scope_entity),
                                             :return_values => IRawContent.create(:content => procedure_return_statements(procedure),
                                                                                  type => scope_entity))
  end

  def procedure_name(procedure)
    procedure.xpath('./subNode:name/scalar:string').text
  end

  def procedure_return_statements(procedure)
    procedure.xpath('./subNode:stmts/scalar:array/node:Stmt_Return')
  end

  def build_global_variable_definitions(raw_content)
    # Prendo tutti gli statements della funzione/metodo corrente
    raw_content.each do |statements|

      # Prendo tutti le variabili globali definite tramite global
      global_variables(statements).each do |global_variable|

        build_global_variable(global_variable)

      end

      # Prendo tutti gli assegnamenti all'interno della funzione corrente
      statements.xpath('./node:Expr_Assign/subNode:var').each do |assignement|

        # puts ModelBuilder::get_LHS assignement

      end

    end
  end

  def global_variables(statements)
    statements.xpath('./node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable')
  end

  def global_variable_name(global_variable)
    global_variable.xpath('./subNode:name/scalar:string').text
  end

  def build_global_variable(global_variable)
    global_variable_name = global_variable_name(global_variable)
    IVariable.create(:unique_name => "#{current_function.unique_name}\\#{global_variable_name}",
                     :name => global_variable_name,
                     :scope => 'global',
                     :i_function => current_function)
  end

  def build_parameters(procedure, type)

    if type == 'function'
      type = :i_function
    elsif type == 'method'
      type = :i_method
    else
      'RAISE EXCEPTION!!!'
    end

    # Prendo tutti i parametri della funzione corrente
    parameters(procedure).each do |parameter|

      parameter_name = parameter_name(parameter)

      IVariable.create(:unique_name => "#{@current_i_procedure.unique_name}\\#{parameter_name}",
                       :name => parameter_name,
                       :scope => 'global',
                       :value => parameter_default_value(parameter),
                       type => @current_i_procedure)

      exit

    end
  end

  def parameter_name(parameter)
    parameter.xpath('./subNode:name/scalar:string').text
  end

  def parameters(procedure)
    procedure.xpath('./subNode:params/scalar:array/node:Param')
  end

  def parameter_default_value(parameter)
    parameter.xpath('./subNode:default')
  end

  ##############################################################################

  def self.get_type(variable)
    self.get_type_hint(variable) or self.get_default_value_type(variable)
  end

  def self.get_type_hint(variable)
    # L'ultimo elemento del nome esteso del parametro che può essere eventualmente il type hint per il parametro
    type_hint = variable.xpath('./subNode:type//subNode:parts//scalar:string').last

    # type_hint può essere Nil
    type_hint.text if type_hint and @scalar_types.include?(type_hint.text)
  end

  def self.get_default_value_type(variable)

    default_value = variable.xpath('./subNode:default/*[1]').first.name

    if default_value === 'Scalar_DNumber'
      'double'
    elsif default_value === 'Scalar_LNumber'
      'int'
    elsif default_value === 'Expr_ConstFetch'
      'bool'
    elsif default_value === 'Expr_Array'
      'array'
    elsif default_value === 'Scalar_String' or @magic_constants.include?(default_value)
      'string'
    else
      '✘'
    end

  end

  def self.get_LHS(node)

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

model_builder = ModelBuilder.new
model_builder.build

INamespace.all.to_a.each do |namespace|
  puts namespace.name
  puts 'with parent ' + (namespace.parent_i_namespace ? namespace.parent_i_namespace.name : '')
  puts namespace.statements
  # p namespace.statements.content unless namespace.statements.nil?
end

exit

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

    # puts ModelBuilder::get_LHS assignement

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
                                        :return_values => IRawContent.create(:content => function.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
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

        # puts ModelBuilder::get_LHS assignement

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
                                      :return_values => IRawContent.create(:content => method.xpath('./subNode:stmts/scalar:array/node:Stmt_Return'),
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

          # puts ModelBuilder::get_LHS assignement

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
