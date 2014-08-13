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
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
end

class AType
  include Mongoid::Document
  has_and_belongs_to_many :variables, class_name: 'AVariable', inverse_of: :types
  field :name, type: String
  index({ name: 1 }, { unique: true })
end

class AProcedure < AScope
  has_many :parameters, class_name: 'AParameter', inverse_of: :procedure
  field :return_values, type: Array
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
end

class ANamespace < AScope
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
