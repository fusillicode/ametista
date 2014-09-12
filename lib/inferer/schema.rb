require "mongoid"

# Per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
I18n.config.enforce_available_locales = true

module ReferableModel
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.field :unique_name, type: String
    base.field :language, type: Language
    base.index({ unique_name: 1 }, { unique: true })
    base.validates :name, presence: true, length: { allow_blank: false }
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

################################################################################

class Language
  include ReferableModel
  include Mongoid::Attributes::Dynamic
  def self.create *attr
    return self.find_by *attr if self.all.count > 0
    super
  end
end

class Scope
  include ReferableModel
  field :statements, type: String
  has_many :variables, class_name: 'Variable', inverse_of: :scope
end

class Procedure < Scope
  has_many :parameters, class_name: 'Parameter', inverse_of: :procedure
end

class Type
  include ReferableModel
  has_and_belongs_to_many :variables, class_name: 'Variable', inverse_of: :types
end

class Variable
  include ReferableModel
  belongs_to :scope, class_name: 'Scope', inverse_of: :variables
end

################################################################################

class Namespace < Scope
  has_many :functions, class_name: 'Function', inverse_of: :namespace
  has_many :klasses, class_name: 'Klass', inverse_of: :namespace
end

class PrimitiveType < Type
end

class Klass < Type
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
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
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :variables
  validate :must_be_in_the_global_namespace

  def must_be_in_the_global_namespace
    if namespace.unique_name != '\\'
      raise "Global Variable #{unique_name} not in the global namespace"
    end
  end
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
