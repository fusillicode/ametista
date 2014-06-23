require "mongoid"

class IScope
  include Mongoid::Document
  belongs_to :parent_scope, class_name: 'IScope', inverse_of: :child_scopes
  has_many :child_scopes, class_name: 'IScope', inverse_of: :parent_scope
  has_many :assignements, class_name: 'IAssignement', inverse_of: :scope
  field :id, type: String
  field :name, type: String
  field :statements, type: String
end

class IAssignement
  include Mongoid::Document
  has_one :variable, class_name: 'IVariable', inverse_of: :assignements
  belongs_to :scope, class_name: 'IScope', inverse_of: :assignements
  field :value, type: String
end

class IVariable
  include Mongoid::Document
  has_many :assignements, class_name: 'IAssignement', inverse_of: :variable
  field :name, type: String
end

class IProcedure < IScope
  has_many :parameters, class_name: 'IParameter', inverse_of: :procedure
  # has_many :local_variables, class_name: 'ILocalVariable', inverse_of: :procedure
  field :return_value, type: String
end

class INamespace < IScope
  belongs_to :parent_namespace, class_name: 'INamespace', inverse_of: :child_namespaces
  has_many :child_namespaces, class_name: 'INamespace', inverse_of: :parent_namespace
  has_many :functions, class_name: 'IFunction', inverse_of: :namespace
  has_many :classes, class_name: 'IClass', inverse_of: :namespace
  # has_many :global_variables, class_name: 'IGlobalVariable', inverse_of: :namespace
end

class IClass < IScope
  has_one :parent_class, class_name: 'IClass', inverse_of: :child_classes
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

class IType
  include Mongoid::Document
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
    @pid = Process.spawn "#{@path} --fork --dbpath #{@database} --logpath #{@log}"
  end

  def stop
    Process.kill('TERM', @pid)
  end

end

class ModelBuilder

  def initialize mongoid_configuration = './mongoid.yml', environment = :development
    @mongoid_configuration = mongoid_configuration
    @environment = environment
    connect
  end

  def connect
    Mongoid.load!(@mongoid_configuration, @environment)
  end

  def initialize_global_variables
  end

end

mongo_daemon = MongoDaemon.new
model_builder = ModelBuilder.new
p ILocalVariable.create(name: 'pippo')
p IVariable.where(_type: 'ILocalVariable').to_a
