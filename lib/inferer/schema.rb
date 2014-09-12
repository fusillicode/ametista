require "mongoid"

# Per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
I18n.config.enforce_available_locales = true

################################################################################

class Scope
  include Mongoid::Document
  field :name, type: String
  field :unique_name, type: String
  field :statements, type: String
  has_many :variables, class_name: 'Variable', inverse_of: :scope
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }
end

class Procedure < Scope
  has_many :parameters, class_name: 'Parameter', inverse_of: :procedure
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
  belongs_to :scope, class_name: 'Scope', inverse_of: :variables
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }
end

################################################################################

class Namespace < Scope
  has_many :functions, class_name: 'Function', inverse_of: :namespace
  has_many :klasses, class_name: 'Klass', inverse_of: :namespace
end

class PrimitiveType < Type
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
  attr_readonly :unique_name
  field :type, type: String, default: 'GLOBALS'
end

class LocalVariable < Variable
  has_many :versions, class_name: 'VariableVersion', inverse_of: :variable
end

class VariableVersion
  include Mongoid::Document
  belongs_to :local_variable, class_name: 'LocalVariable', inverse_of: :versions
end

class Property < Variable
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
end

class Parameter < Variable
  belongs_to :procedure, class_name: 'Procedure', inverse_of: :parameters
end
