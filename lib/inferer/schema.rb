require "mongoid"

# Per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
I18n.config.enforce_available_locales = true

module UniquelyIdentifiable
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.field :unique_name, type: String
    base.index({ unique_name: 1 }, { unique: true })
    base.validates :name, presence: true, length: { allow_blank: false }
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module LanguageDependant
  def self.included base
    base.include Mongoid::Document
    base.belongs_to :language, class_name: 'Language'
    base.after_initialize do
      self.language = Language.first()
    end
  end
end

module Singleton
  def self.included base
    base.include Mongoid::Document
    base.validate :enforce_singleton, on: :create
    def initialize *args
      enforce_singleton
      super
    end
    def enforce_singleton
      raise "there can be only one #{self.class}." unless is_singleton?
    end
    def is_singleton?
      self.class.all.count.zero?
    end
  end
end

module ContainsGlobalState
  def self.included base
    base.include Mongoid::Document
    has_many :variables, class_name: 'GlobalVariable', inverse_of: :state_container
  end
end

module ContainsLocalState
  def self.included base
    base.include Mongoid::Document
    base.has_many :variables, class_name: 'LocalVariable', inverse_of: :state_container
  end
end

################################################################################

class StateContainer
  include LanguageDependant
  include UniquelyIdentifiable
  has_many :variables, class_name: 'Variable', inverse_of: :state_container
end

class Variable
  include LanguageDependant
  include UniquelyIdentifiable
  belongs_to :state_container, class_name: 'StateContainer', inverse_of: :variables
end

class Procedure < StateContainer
  field :statements, type: String
  has_many :variables, class_name: 'LocalVariable', inverse_of: :state_container
  has_many :parameters, class_name: 'Parameter', inverse_of: :state_container
end

class Type
  include LanguageDependant
  include UniquelyIdentifiable
  has_and_belongs_to_many :variables_versions, class_name: 'VariableVersion', inverse_of: :types
end

################################################################################

class Language
  include Singleton
  include UniquelyIdentifiable
  include Mongoid::Attributes::Dynamic
end

class Namespace < StateContainer
  include ContainsLocalState
  field :statements, type: String
  has_many :functions, class_name: 'Function', inverse_of: :namespace
  has_many :klasses, class_name: 'Klass', inverse_of: :namespace
  # se il namespace che sto costruendo e/o utilizzando è quello globale
  # allora le variabili che ci vado ad associare devono essere globali
  after_initialize do
    extend ContainsGlobalState if is_global_namespace?
  end
  def is_global_namespace?
    unique_name = language.global_namespace['unique_name']
  end
end

class Klass < StateContainer
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :variables, class_name: 'Property', inverse_of: :state_container
end

class PrimitiveType < Type
end

# Alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod < Procedure
  belongs_to :klass, class_name: 'Klass', inverse_of: :methods
end

class Function < Procedure
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :functions
end

class MultipleVersionsVariable < Variable
  has_many :versions, class_name: 'VariableVersion', inverse_of: :local_variable
end

class SingleVersionVariable < Variable
  has_one :version, class_name: 'VariableVersion', inverse_of: :global_variable
end

class GlobalVariable < SingleVersionVariable
  attr_readonly :unique_name, :namespace
  field :type, type: String, default: 'GLOBALS'
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :variables
  after_initialize do
    self.namespace = Namespace.find_or_create_by(language.global_namespace)
  end
  # validate :is_in_global_namespace, on: :create
  # def is_in_global_namespace
  #   self.errors.add :base, "global Variable #{unique_name} isn't in the global namespace" if namespace.unique_name != language.global_namespace['unique_name']
  # end
end

class LocalVariable < MultipleVersionsVariable
end

class VariableVersion
  include LanguageDependant
  include UniquelyIdentifiable
  belongs_to :single_version_variable, class_name: 'SingleVersionVariable', inverse_of: :version
  belongs_to :multiple_versions_variable, class_name: 'MultipleVersionsVariable', inverse_of: :versions
  has_many :types, class_name: 'Type', inverse_of: :variables_versions
end

class Property < MultipleVersionsVariable
  belongs_to :state_container, class_name: 'Klass', inverse_of: :variables
end

class Parameter < SingleVersionVariable
  belongs_to :state_container, class_name: 'Procedure', inverse_of: :variables
end
