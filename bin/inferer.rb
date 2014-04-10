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

  reference :parent_namespace, :INamespace
  reference :statements, :IRawContent

  collection :classes, :IClass, :namespace
  collection :functions, :IProcedure, :namespace
end

class IClass < Ohm::Model
  index :name
  attribute :name

  reference :namespace, :INamespace

  collection :methods, :IProcedure, :class
  collection :properties, :IProperty, :class
end

class IProperty < Ohm::Model
  index :name
  attribute :name

  reference :class, :IClass
end

class IMethod < Ohm::Model
  index :name
  attribute :name

  reference :class, :IClass
  reference :statements, :IRawContent
  reference :return_value, :IRawContent

  collection :parameters, :IVariable, :method
  collection :local_variables, :IVariable, :method
end

class IFunction < Ohm::Model
  index :name
  attribute :name

  reference :namespace, :INamespace
  reference :statements, :IRawContent
  reference :return_value, :IRawContent

  collection :parameters, :IVariable, :function
  collection :local_variables, :IVariable, :function
end

class IRawContent < Ohm::Model
  attribute :content

  reference :namespace, :INamespace
  reference :method, :IMethod
  reference :function, :IFunction
end

class IVariable < Ohm::Model
  index :name
  attribute :name
  attribute :value
  attribute :type

  reference :namespace, :INamespace
  reference :method, :IMethod
  reference :function, :IFunction

  def local?
    self.method or self.function or self.namespace.name === '\\'
  end

  def global?
    not self.local?
  end

end

scalar_types = ['bool', 'int', 'double', 'string', 'array', 'null']
magic_constants = ['__LINE__', '__FILE__', '__DIR__', '__FUNCTION__', '__CLASS__', '__TRAIT__', '__METHOD__', '__NAMESPACE__']

def getParameterType parameter, scalar_types, magic_constants

  # L'ultimo elemento del nome esteso del parametro che può essere eventualmente il type hint per il parametro
  type_hint = parameter.xpath('./subNode:type//subNode:parts//scalar:string').last.text

  return type_hint if scalar_types.include? type_hint

  default_value = parameter.xpath('./subNode:default/*[1]').first.name

  case default_value
  # 1.2 -> node:Scalar_DNumber
  when 'Scalar_DNumber'
    'double'
  # 1 -> node:Scalar_LNumber
  when 'Scalar_LNumber'
    'int'
  # true, false, null -> node:Expr_ConstFetch
  when 'Expr_ConstFetch'
    'bool'
  # array() -> node:Expr_Array
  when 'Expr_Array'
    'array'
  # 'asd' -> node:Scalar_String
  # __FILE__ -> node:Scalar_FileConst
  when 'Scalar_String', ('Scalar_FileConst' and magic_constants.include? scalar_types)
    'string'
  else
    'DON\'T KNOW'
  end

end

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

      parent_namespace = INamespace.create(:name             => current_namespace_name,
                                           :parent_namespace => parent_namespace)

    end

  end

  # Prendo tutti gli statements che non siano funzioni o classi all'interno del namespace corrente
  parent_namespace.statements = IRawContent.create(:content => namespace.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]'), :namespace => parent_namespace)
  # Il save serve per aggiornare effettivamente l'istanza INamespace parent_namespace!
  parent_namespace.save

  # Prendo tutte le funzioni all'interno del namespace corrente
  namespace.xpath('./subNode:stmts/scalar:array/node:Stmt_Function').each do |function|

    current_function = IFunction.create(:name       => function.xpath('./subNode:name/scalar:string').text,
                                        :namespace  => parent_namespace,
                                        :statements => IRawContent.create(:content  => function.xpath('./subNode:stmts'),
                                                                          :function => current_function))

    # Prendo tutti i parametri della funzione corrente
    function.xpath('./subNode:params//node:Param').each do |parameter|

      IVariable.create(:name     => parameter.xpath('./subNode:name/scalar:string').text,
                       :type     => getParameterType(parameter, scalar_types, magic_constants),
                       :function => current_function)

    end

  end

end

INamespace.all.to_a.each do |namespace|
  puts namespace.name + ' with parent ' + (namespace.parent_namespace ? namespace.parent_namespace.name : '')
  p namespace.statements.content unless namespace.statements.nil?
end

exit

# def get_lhs node

#   node = node.xpath('./*[1]')[0]

#   case node.name

#     when 'Expr_Variable'
#       node.xpath('./subNode:name/scalar:string').text

#     when 'Expr_PropertyFetch'
#       get_lhs(node.xpath('./subNode:var')) + '->' + get_lhs(node.xpath('./subNode:name'))

#     when 'Expr_ArrayDimFetch'
#       get_lhs(node.xpath('./subNode:var')) + '[' + node.xpath('./subNode:dim//subNode:value/*').text + ']'

#     when 'Expr_StaticPropertyFetch'
#       node.xpath('./subNode:class/node:Name//scalar:string')[0].text + '::' + node.xpath('./subNode:name/scalar:string')[0].text

#     when 'Expr_Assign'
#       get_lhs node.xpath('./subNode:var')

#     when 'Expr_Concat'
#       get_lhs(node.xpath('./subNode:left')) + '.' + get_lhs(node.xpath('./subNode:right'))

#     when 'Scalar_String'
#       node.xpath('./subNode:value/*').text

#     when 'string'
#       node.text

#     else
#       '✘'

#   end

# end

# # Classes
# xml.xpath('.//node:Stmt_Class').each do |classInXML|

#   # class Iname
#   puts 'C --- ' + classInXML.xpath('.//subNode:namespacedName//scalar:string')[0..-1].to_a.join('/')

#   # class Imethods
#   classInXML.xpath('.//node:Stmt_ClassMethod').each do |method|

#     # class Imethod name
#     puts 'M --- ' + method.xpath('./subNode:name/scalar:string').text

#     # class Imethod args
#     method.xpath('.//node:Param').each do |param|
#       puts 'A --- ' + param.xpath('./subNode:name/scalar:string').text
#     end

#     # devo prendere prima tutti gli Expr_PropertyFetch e gli Expr_ArrayDimFetch all'interno di ciascun singolo Expr_Assign.
#     # ogni Expr_PropertyFetch o Expr_ArrayDimFetch ha un subNode:var e un subNode:name.
#     # il subNode:var può essere a sua volta un Expr_PropertyFetch o un Expr_ArrayDimFetch mentre il subNode:name è quello che è
#     # posto alla destra del Expr_PropertyFetch o del Expr_ArrayDimFetch a seconda dei casi

#     method.xpath('.//node:Expr_Assign/subNode:var').each do |lhs|
#       p get_lhs lhs
#     end

#     #   p
#     #   # p lhs.xpath('.//node:Expr_ArrayDimFetch/subNode[local-name() = \'name\' or local-name() = \'dim\']/scalar[local-name() = \'string\' or local-name() = \'string\']').text
#     # end

#   end

# end

# # Functions
# xml.xpath('.//node:Stmt_Function').each do |function|

#   # Function name
#   puts 'F --- ' + function.xpath('.//subNode:namespacedName//scalar:string').text

#   # Function args
#   function.xpath('.//node:Param').each do |param|
#     puts 'A --- ' + param.xpath('.//node:Name_FullyQualified/subNode:parts//scalar:string[position() < last()]')[0..-1].to_a.join('/') + '/' + param.xpath('./subNode:name/scalar:string').text
#   end

# end

