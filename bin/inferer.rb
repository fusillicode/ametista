#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"

class MyNamespace < Ohm::Model
  attribute :name
  reference :parent_namespace, :Namespace
  collection :classes, :Class
  collection :functions, :Procedure
  collection :raw_statements, :RawStatements
end

class MyClass < Ohm::Model
  attribute :name
  reference :namespace, :Namespace
  collection :methods, :Procedure
  collection :properties, :Property
end

class MyProperty < Ohm::Model
  attribute :name
  reference :class, :MyClass
end

class MyProcedure < Ohm::Model
  attribute :name
  reference :class, :Class
  reference :namespace, :Namespace
  collection :parameters, :VariableModel
  collection :statements, :RawStatements
  collection :local_variables, :VariableModel
end

class MyRawStatements < Ohm::Model
  reference :procedure, :Procedure
end

class MyVariable < Ohm::Model
  attribute :name
  reference :method, :Procedure
  reference :function, :Procedure
  reference :namespace, :Namespace

  def local?
    self.type === :local
  end

  def global?
    not self.local?
  end

  def type
    if self.method or self.function
      :local
    elsif self.namespace
      :global
    else
      "are you fucking kiddin' me?!"
    end
  end

  def scope
    if self.local?
      self.method or self.function
    elsif self.global?
      '\\'
  end

end

Ohm.connect :url => "redis://127.0.0.1:6379"

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

# redis = Redis.new

# xml = Nokogiri::XML redis.get './test_codebase/controllers/front/1.php'

# # Namespace
# xml.xpath('.//node:Stmt_Namespace').each do |namespace|
#   puts 'N --- ' + namespace.xpath('./subNode:name/node:Name/subNode:parts//scalar:string').text
# end

# # Classes
# xml.xpath('.//node:Stmt_Class').each do |classInXML|

#   # class Myname
#   puts 'C --- ' + classInXML.xpath('.//subNode:namespacedName//scalar:string')[0..-1].to_a.join('/')

#   # class Mymethods
#   classInXML.xpath('.//node:Stmt_ClassMethod').each do |method|

#     # class Mymethod name
#     puts 'M --- ' + method.xpath('./subNode:name/scalar:string').text

#     # class Mymethod args
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

