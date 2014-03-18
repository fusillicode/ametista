#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"

class NamespaceModel < Ohm::Model
  attribute :name
  reference :parent, :NamespaceModel
end

class ClassModel < Ohm::Model
  attribute :name
  reference :namespace, :NamespaceModel
  set :methods, :MethodModel
end

class ProcedureModel < Ohm::Model
  attribute :name
end

class MethodModel < Ohm::Model
  attribute :name
  reference :class, :ClassModel
end

class FunctionModel < Ohm::Model
  attribute :name
  reference :namespace, :NamespaceModel
end

class PropertyModel < Ohm::Model
  attribute :name
end

class RawStatements < Ohm::Model
  reference :procedure, :ProcedureModel
end

class VariableModel < Ohm::Model
  attribute :name
end

Ohm.connect :url => "redis://127.0.0.1:6379"

# xml = Nokogiri.parse redis.get './test_codebase/classes/log/AbstractLogger.php'
# xml.xpath('//node:*').first

event = Event.create :name => "Ohm Worldwide Conference 2031"
event = Event[3]
p Event.all
