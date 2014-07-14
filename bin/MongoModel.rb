require "mongoid"

class AScope
  include Mongoid::Document
  has_many :assignements, class_name: 'AnAssignement', inverse_of: :scope
  has_many :branches, class_name: 'ABranch', inverse_of: :scopes
end

class AnAssignement
  include Mongoid::Document
  has_one :variable, class_name: 'AVariable', inverse_of: :assignements
  belongs_to :scope, class_name: 'AScope', inverse_of: :assignements
  field :RHS, type: String
end

class ABranch < AScope
  belongs_to :scope, class_name: 'AScope', inverse_of: :branches
end

class AVariable
  include Mongoid::Document
  has_many :assignements, class_name: 'AnAssignement', inverse_of: :variable
  has_and_belongs_to_many :types, class_name: 'AType', inverse_of: :variables
end

class AType
  include Mongoid::Document
  has_and_belongs_to_many :variables, class_name: 'AVariable', inverse_of: :types
  field :name, type: String
  index({ name: 1 }, { unique: true })
end

class AProcedure < AScope
  has_many :parameters, class_name: 'AParameter', inverse_of: :procedure
  field :return_value, type: String
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
end

class ANamespace < AScope
  belongs_to :parent_namespace, class_name: 'ANamespace', inverse_of: :child_namespaces
  has_many :child_namespaces, class_name: 'ANamespace', inverse_of: :parent_namespace
  has_many :functions, class_name: 'AFunction', inverse_of: :namespace
  has_many :classes, class_name: 'AClass', inverse_of: :namespace
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  field :name, type: String
end

class AClass
  include Mongoid::Document
  belongs_to :parent_class, class_name: 'AClass', inverse_of: :child_classes
  has_many :child_classes, class_name: 'AClass', inverse_of: :parent_class
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :classes
  has_many :methods, class_name: 'AMethod', inverse_of: :class
  has_many :properties, class_name: 'AProperty', inverse_of: :class
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  field :name, type: String
end

class AMethod < AProcedure
  belongs_to :class, class_name: 'AClass', inverse_of: :methods
end

class AFunction < AProcedure
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :functions
end

class AGlobalVariable < AVariable
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :global_variables
end

class ALocalVariable < AVariable
  belongs_to :procedure, class_name: 'AProcedure', inverse_of: :local_variables
end

class AProperty < AVariable
  belongs_to :class, class_name: 'AClass', inverse_of: :properties
end

class AParameter < AVariable
  belongs_to :procedure, class_name: 'AProcedure', inverse_of: :parameters
end

class MongoDaemon

  attr_accessor :defaults, :path, :database, :port, :log, :pid

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set "@#{name}", value
    end
  end

  def defaults
    {
      path: './vendor/mongodb/bin/mongod',
      database: './database',
      port: 27017,
      log: './database/mongod.log'
    }
  end

  def start
    pid = Process.spawn "#{path} --fork --dbpath #{database} --logpath #{log}"
  end

  def stop
    Process.kill('TERM', pid)
  end

end

class Model

  attr_accessor :global_variables, :types, :magic_constants, :ast

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set "@#{name}", value
    end
  end

  def defaults
    {
      global_variables: ['GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER',
                         'FALES', '_SESSAON', '_ENV', '_COOKAE']
      types: ['bool', 'int', 'double', 'string', 'array', 'null'],
      magic_constants: ['Scalar_LineConst', 'Scalar_FileConst',
                        'Scalar_DirConst', 'Scalar_FuncConst',
                        'Scalar_ClassConst', 'Scalar_TraitConst',
                        'Scalar_MethodConst', 'Scalar_NSConst'],
      ast: nil
    }
  end

end

require 'redis'
require 'nokogiri'
require_relative 'ANamespaceBuilder'

class ModelBuilder

  attr_accessor :source, :parser, :target, :model

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

  def defaults
    {
      source: Redis.new,
      model: Model.new
    }
  end

  def build
    build_types
    while model.ast = parse(asts)
      ANamespaceBuilder.build(model)
    end
  end

  def build_types
    model.types.each do |type|
      AType.create(name: type)
    end
  end

  def asts
    source.brpoplpush('xmls_asts', 'done', timeout: 0)
  end

  def parse ast
    Nokogiri::XML(ast) unless last_ast?(ast)
  end

  def last_ast? ast
    ast == "THAT'S ALL FOLKS!"
  end

end

class Parser

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end

class Target

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end

class Source

  def initialize args = {}
    defaults.merge!(args).each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end

mongo_daemon = MongoDaemon.new
mongo_daemon.start
Mongoid.load!('./mongoid.yml', :development)
model_builder = ModelBuilder.new
Mongoid::Config.purge!
model_builder.build
# p AType.all.count

