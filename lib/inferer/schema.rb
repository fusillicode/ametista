require "mongoid"

################################################################################

class Scope
  include Mongoid::Document
  has_many :assignements, class_name: 'Assignement', inverse_of: :scope
  has_many :branches, class_name: 'Branch', inverse_of: :scopes
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class Procedure < Scope
  has_many :parameters, class_name: 'Parameter', inverse_of: :procedure
  field :return_values, type: Array
end

class Type
  include Mongoid::Document
  has_and_belongs_to_many :variables, class_name: 'Variable', inverse_of: :types
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }
end

class Variable
  include Mongoid::Document
  has_many :assignements, class_name: 'Assignement', inverse_of: :variable
  has_and_belongs_to_many :types, class_name: 'Type', inverse_of: :variables
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }
end

################################################################################

class Assignement
  include Mongoid::Document
  belongs_to :variable, class_name: 'Variable', inverse_of: :assignements
  belongs_to :scope, class_name: 'Scope', inverse_of: :assignements
  field :rhs, type: String
end

class Branch < Scope
  belongs_to :scope, class_name: 'Scope', inverse_of: :branches
end

class Namespace < Scope
  has_many :functions, class_name: 'Function', inverse_of: :namespace
  has_many :klasses, class_name: 'Klass', inverse_of: :namespace
end

class BasicType < Type
end

class Klass < Type
  include Mongoid::Document
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :properties, class_name: 'Property', inverse_of: :klass
end

# Alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod < Procedure
  belongs_to :klass, class_name: 'Klass', inverse_of: :methods
end

class Function < Procedure
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :functions
end

class GlobalVariable < Variable
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :global_variables
end

class LocalVariable < Variable
  belongs_to :procedure, class_name: 'Procedure', inverse_of: :local_variables
end

class Property < Variable
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
end

class Parameter < Variable
  belongs_to :procedure, class_name: 'Procedure', inverse_of: :parameters
end
