require "mongoid"

# Per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
I18n.config.enforce_available_locales = true

################################################################################

class Scope
  include Mongoid::Document
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  validates :name, presence: true, length: { allow_blank: false }
  validates :unique_name, presence: true, length: { allow_blank: false }

  # Per ottenere i discendenti della classe Scope (i.e. tutte le classi che la specializzano)
  # def self.descendants
  #   ObjectSpace.each_object(Class).select { |klass| klass < self }
  # end
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
  has_and_belongs_to_many :types, class_name: 'Type', inverse_of: :variables
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

class Superglobal < GlobalVariable
  field :type, type: String
end

class LocalVariable < Variable
  belongs_to :procedure, class_name: 'Procedure', inverse_of: :local_variables
  has_many :scopes, class_name: 'VariableScope', inverse_of: :variable
end

class VariableScope
  include Mongoid::Document
  belongs_to :variable, class_name: 'Variable', inverse_of: :scopes
end

class Property < Variable
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
end

class Parameter < Variable
  belongs_to :procedure, class_name: 'Procedure', inverse_of: :parameters
end
