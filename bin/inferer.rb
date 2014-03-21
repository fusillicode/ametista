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
  puts 'C --- ' + classInXML.xpath('.//subNode:namespacedName//scalar:string')[0..-1].to_a.join('/')

  # Class methods
  classInXML.xpath('.//node:Stmt_ClassMethod').each do |method|

    # Class method name
    puts 'M --- ' + method.xpath('./subNode:name/scalar:string').text

    # Class method args
    method.xpath('.//node:Param').each do |param|
      puts 'A --- ' + param.xpath('./subNode:name/scalar:string').text
    end

    # devo prendere prima tutti gli Expr_PropertyFetch e gli Expr_ArrayDimFetch all'interno di ciascun singolo Expr_Assign.
    # ogni Expr_PropertyFetch o Expr_ArrayDimFetch ha un subNode:var e un subNode:name.
    # il subNode:var può essere a sua volta un Expr_PropertyFetch o un Expr_ArrayDimFetch mentre il subNode:name è quello che è
    # posto alla destra del Expr_PropertyFetch o del Expr_ArrayDimFetch a seconda dei casi

    p method.xpath('.//node:Expr_Assign//subNode:dim//scalar:int').text
    #   p
    #   # p lhs.xpath('.//node:Expr_ArrayDimFetch/subNode[local-name() = \'name\' or local-name() = \'dim\']/scalar[local-name() = \'string\' or local-name() = \'string\']').text
    # end

  end

end

# Functions
xml.xpath('.//node:Stmt_Function').each do |function|

  # Function name
  puts 'F --- ' + function.xpath('.//subNode:namespacedName//scalar:string').text

  # Function args
  function.xpath('.//node:Param').each do |param|
    puts 'A --- ' + param.xpath('.//node:Name_FullyQualified/subNode:parts//scalar:string[position() < last()]')[0..-1].to_a.join('/') + '/' + param.xpath('./subNode:name/scalar:string').text
  end

end

