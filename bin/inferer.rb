#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"

# class NamespaceModel < Ohm::Model
#   attribute :name

#   reference :parentNamespace, :NamespaceModel

#   collection :classes, :ClassModel
#   collection :functions, :ProcedureModel
# end

# class ClassModel < Ohm::Model
#   attribute :name

#   reference :namespace, :NamespaceModel
#   set :methods, :MethodModel
#   set :properties, :PropertyModel

# end

# class ProcedureModel < Ohm::Model
#   attribute :name

#   reference :class, :ClassModel
#   reference :namespace, :NamespaceModel
#   reference :statements, :RawStatements

# end

# class PropertyModel < Ohm::Model
#   attribute :name
# end

# class RawStatements < Ohm::Model
#   reference :procedure, :ProcedureModel
# end

# class VariableModel < Ohm::Model
#   attribute :name
#   reference :scope, :ProcedureModel
# end

# Ohm.connect :url => "redis://127.0.0.1:6379"

redis = Redis.new

xml = Nokogiri::XML redis.get './test_codebase/controllers/front/1.php'

# Classes
xml.xpath('.//node:Stmt_Class').each do |classInXML|

  # Class name
  puts 'C --- ' + classInXML.xpath('.//subNode:namespacedName//scalar:string').text

  # Class methods
  classInXML.xpath('.//node:Stmt_ClassMethod').each do |method|

    # Class method name
    puts 'M --- ' + method.xpath('./subNode:name/scalar:string').text

    # Class method args
    method.xpath('.//node:Param').each do |param|
      puts 'A --- ' + param.xpath('.//subNode:name//scalar:string').text
    end

    # Class properties
    puts method.xpath(".//node:Expr_Assign/subNode:var/node:Expr_PropertyFetch/subNode:var[1]//subNode:name/scalar:string[. = 'this']")
    # puts method.xpath(".//node:Expr_Assign/subNode:var/node:Expr_ArrayDimFetch/subNode:var[1]//subNode:name/scalar:string[. = 'this']")

  end

end

# Functions
xml.xpath('.//node:Stmt_Function').each do |function|

  # Function name
  puts 'F --- ' + function.xpath('.//subNode:namespacedName//scalar:string').text

  # Function args
  function.xpath('.//node:Param').each do |param|
    puts 'P --- ' + param.xpath('.//subNode:name//scalar:string').text
  end

end

# # Assignements
# xml.xpath('.//node:Expr_Assign').each do |assignement|

#   # LHS
#   assignement.xpath('.//subNode:var')

#   # RHS

# end


# xml.xpath('//node:Stmt_Class').children.xpath('//node:Stmt_ClassMethod').each do |method|
#   puts method.children.xpath('//subNode:name').last
# end

# event = Event.create :name => "Ohm Worldwide Conference 2031"
# event = Event[3]
# p Event.all
