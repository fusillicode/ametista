require "mongoid"
include EnforceAvailableLocales

module IsIdentifiableWithNameAnd
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
    base.field :unique_name, type: String, default: ->{ unique_name }
    base.index({ unique_name: 1 }, { unique: true })
  end
end

module IsIdentifiableWithNameAndUniqueName
  def self.included base
    base.include Mongoid::Document
    base.include IsIdentifiableWithNameAnd
    base.field :unique_name, type: String, overwrite: true
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module IsIdentifiableWithNameAndType
  def self.included base
    base.include IsIdentifiableWithNameAnd
    base.field :type, type: String, default: 'GLOBALS'
  end
  def unique_name
    "#{type}[#{name}]"
  end
end

module IsIdentifiableWithNameAndKlass
  def self.included base
    base.include IsIdentifiableWithNameAnd
  end
  def unique_name
    reference_language
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

module ReferencesLanguage
  def self.included base
    base.include Mongoid::Document
    base.belongs_to :language, class_name: 'Language'
    base.after_initialize do
      reference_language
    end
  end
  def reference_language
    self.language ||= Language.first()
  end
end

module IsSingleton
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

module ContainsGlobalVariables
  def self.included base
    base.include Mongoid::Document
    base.has_many :global_variables, as: :global_scope
  end
end

module ContainsLocalVariables
  def self.included base
    base.include Mongoid::Document
    base.has_many :local_variables, as: :local_scope
  end
end

module HasOneVariableVersion
  def self.included base
    base.include Mongoid::Document
    base.has_one :variable_version, as: :versionable
  end
end

module HasManyVariableVersions
  def self.included base
    base.include Mongoid::Document
    base.has_many :variable_versions, as: :versionable
  end
end

module IsAType
  def self.included base
    base.include ReferencesLanguage
    base.include IsIdentifiableWithNameAndUniqueName
    base.has_and_belongs_to_many :variables_versions, class_name: 'VariableVersion', inverse_of: :types
  end
end

module IsAProcedure
  def self.included base
    base.include ReferencesLanguage
    base.include IsIdentifiableWithNameAndUniqueName
    base.include ContainsLocalVariables
    base.field :statements, type: String
    base.has_many :parameters, as: :procedure
  end
end

################################################################################

class Language
  include IsSingleton
  include IsIdentifiableWithNameAndUniqueName
  include Mongoid::Attributes::Dynamic
end

class Namespace
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  field :statements, type: String
  has_many :functions, class_name: 'Function', inverse_of: :namespace
  has_many :klasses, class_name: 'Klass', inverse_of: :namespace
  after_initialize do
    extend (is_global_namespace? ? ContainsGlobalVariables : ContainsLocalVariables)
  end
  def is_global_namespace?
    unique_name.eql? language.global_namespace['unique_name']
  end
end

class Klass
  include IsAType
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :properties, class_name: 'Property', inverse_of: :klass
end

class PrimitiveType
  include IsAType
end

# alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod
  include IsAProcedure
  belongs_to :klass, class_name: 'Klass', inverse_of: :methods
end

class Function
  include IsAProcedure
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :functions
end

class GlobalVariable
  include ReferencesLanguage
  include IsIdentifiableWithNameAndType
  include HasOneVariableVersion
  belongs_to :global_scope, polymorphic: true
  after_initialize do
    self.global_scope = Namespace.find_or_create_by(language.global_namespace)
  end
end

class LocalVariable
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  belongs_to :local_scope, polymorphic: true
end

class Property
  include ReferencesLanguage
  include IsIdentifiableWithNameAndKlass
  include HasOneVariableVersion
  field :type, type: Array
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
end

class Parameter
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  include HasOneVariableVersion
  belongs_to :procedure, polymorphic: true
end

class VariableVersion
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  belongs_to :versionable, polymorphic: true
  has_many :types, class_name: 'Type', inverse_of: :variables_versions
end
