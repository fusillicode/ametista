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

Ohm.connect :url => "redis://127.0.0.1:6379"

# xml = Nokogiri.parse redis.get './test_codebase/classes/log/AbstractLogger.php'
# xml.xpath('//node:*').first

event = Event.create :name => "Ohm Worldwide Conference 2031"
event = Event[3]
p Event.all
