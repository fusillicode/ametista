require "mongoid"

class IScope
  include Mongoid::Document
  has_many :assignements, class_name: 'IAssignement', inverse_of: :scope
  has_many :branches, class_name: 'IBranch', inverse_of: :scopes
end

class IBranch < IScope
  belongs_to :scope, class_name: 'IScope', inverse_of: :branches
end

class IAssignement
  include Mongoid::Document
  has_one :variable, class_name: 'IVariable', inverse_of: :assignements
  belongs_to :scope, class_name: 'IScope', inverse_of: :assignements
  field :RHS, type: String
end

class IVariable
  include Mongoid::Document
  has_many :assignements, class_name: 'IAssignement', inverse_of: :variable
  has_and_belongs_to_many :types, class_name: 'IType', inverse_of: :variables
end

class IType
  include Mongoid::Document
  has_and_belongs_to_many :variables, class_name: 'IVariable', inverse_of: :types
  field :name, type: String
end

class IProcedure < IScope
  has_many :parameters, class_name: 'IParameter', inverse_of: :procedure
  field :id, type: String
  field :name, type: String
  field :return_value, type: String
end

class INamespace < IScope
  belongs_to :parent_namespace, class_name: 'INamespace', inverse_of: :child_namespaces
  has_many :child_namespaces, class_name: 'INamespace', inverse_of: :parent_namespace
  has_many :functions, class_name: 'IFunction', inverse_of: :namespace
  has_many :classes, class_name: 'IClass', inverse_of: :namespace
  field :id, type: String
  field :name, type: String
end

class IClass
  include Mongoid::Document
  belongs_to :parent_class, class_name: 'IClass', inverse_of: :child_classes
  has_many :child_classes, class_name: 'IClass', inverse_of: :parent_class
  belongs_to :namespace, class_name: 'INamespace', inverse_of: :classes
  has_many :methods, class_name: 'IMethod', inverse_of: :class
  has_many :properties, class_name: 'IProperty', inverse_of: :class
end

class IMethod < IProcedure
  belongs_to :class, class_name: 'IClass', inverse_of: :methods
end

class IFunction < IProcedure
  belongs_to :namespace, class_name: 'INamespace', inverse_of: :functions
end

class IGlobalVariable < IVariable
  belongs_to :namespace, class_name: 'INamespace', inverse_of: :global_variables
end

class ILocalVariable < IVariable
  belongs_to :procedure, class_name: 'IProcedure', inverse_of: :local_variables
end

class IProperty < IVariable
  belongs_to :class, class_name: 'IClass', inverse_of: :properties
end

class IParameter < IVariable
  belongs_to :procedure, class_name: 'IProcedure', inverse_of: :parameters
end

class MongoDaemon

  def initialize path = './vendor/mongodb/bin/mongod', database = './database', port = 27017, log = './database/mongod.log'
    @path = path
    @database = database
    @port = port
    @log = log
    start
  end

  def start
    p "#{@path} --fork --dbpath #{@database} --logpath #{@log}"
    @pid = Process.spawn "#{@path} --fork --dbpath #{@database} --logpath #{@log}"
  end

  def stop
    Process.kill('TERM', @pid)
  end

end

class Model

  attr_accessor :global_variables, :types, :magic_constants, :ast

  def initialize
    @global_variables = ['GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER',
                         'FILES', '_SESSION', '_ENV', '_COOKIE']
    @types = ['bool', 'int', 'double', 'string', 'array', 'null']
    @magic_constants = ['Scalar_LineConst', 'Scalar_FileConst',
                        'Scalar_DirConst', 'Scalar_FuncConst',
                        'Scalar_ClassConst', 'Scalar_TraitConst',
                        'Scalar_MethodConst', 'Scalar_NSConst']
    @ast = nil
  end

end

require 'redis'
require 'nokogiri'

class ModelBuilder

  def initialize mongoid_configuration = './mongoid.yml', environment = :development, redis = nil, model = nil
    @mongoid_configuration = mongoid_configuration
    @environment = environment
    connect
    @redis = redis || Redis.new
    @model = model || Model.new
    build_types
    exit
  end

  def connect
    Mongoid.load!(@mongoid_configuration, @environment)
  end

  def build
    while @model.ast = parse(asts)
      INamespaceBuilder.build(@model)
    end
  end

  def build_types
    @model.types.each do |type|
      IType.create(name: type)
    end
  end

  def asts
    redis.brpoplpush('xmls_asts', 'done', :timeout => 0)
  end

  def parse ast
    Nokogiri::XML(ast) unless last_ast?(ast)
  end

  def last_ast? ast
    ast == "THAT'S ALL FOLKS!"
  end

end

mongo_daemon = MongoDaemon.new
model_builder = ModelBuilder.new
p IType.all.to_a
