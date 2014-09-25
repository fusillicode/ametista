require "mongoid"

# per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
I18n.config.enforce_available_locales = true

module IsUniquelyIdentifiable
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
    base.field :unique_name, type: String
    base.index({ unique_name: 1 }, { unique: true })
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module IsUniquelyIdentifiableWithNameAndType
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
    base.field :unique_name, type: String, default: ->{ "#{type}[#{name}]" }
    base.index({ unique_name: 1 }, { unique: true })
    base.field :type, type: String, default: 'GLOBALS'
  end
end

module IsUniquelyIdentifiableWithNameAndKlass
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
    # TODO bisogna aggiungere la validazione in merito alla presenza di una klass
    base.field :unique_name, type: String, default: ->{ "#{klass.unique_name}#{language.namespace_separator}#{name}" }
    base.index({ unique_name: 1 }, { unique: true })
  end
end

module ReferencesLanguage
  def self.included base
    base.include Mongoid::Document
    base.belongs_to :language, class_name: 'Language'
    base.after_initialize do
      self.language = Language.first()
    end
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
    base.include IsUniquelyIdentifiable
    base.has_and_belongs_to_many :variables_versions, class_name: 'VariableVersion', inverse_of: :types
  end
end

module IsAProcedure
  def self.included base
    base.include ReferencesLanguage
    base.include IsUniquelyIdentifiable
    base.include ContainsLocalVariables
    base.field :statements, type: String
    base.has_many :parameters, as: :procedure
  end
end

################################################################################

class Language
  include IsSingleton
  include IsUniquelyIdentifiable
  include Mongoid::Attributes::Dynamic
end

class Namespace
  include ReferencesLanguage
  include IsUniquelyIdentifiable
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
  belongs_to :root_klass, class_name: 'Klass', inverse_of: :leaf_klasses
  has_many :leaf_klasses, class_name: 'Klass', inverse_of: :root_klass
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :properties, class_name: 'Property', inverse_of: :klass

  def root_klass
    @root_klass ||= retrive_root_klass
  end

  def retrive_root_klass klass = nil
    return retrive_root_klass(klass.parent_klass) if klass && klass.has_parent_klass?
    return retrive_root_klass(self.parent_klass) if not(klass) && self.has_parent_klass?
    return self if not(klass)
    return klass
  end
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
  include IsUniquelyIdentifiableWithNameAndType
  include HasOneVariableVersion
  belongs_to :global_scope, polymorphic: true
  after_initialize do
    self.global_scope = Namespace.find_or_create_by(language.global_namespace)
  end
end

class LocalVariable
  include ReferencesLanguage
  include IsUniquelyIdentifiable
  belongs_to :local_scope, polymorphic: true
end

class Property
  include ReferencesLanguage
  include IsUniquelyIdentifiableWithNameAndKlass
  include HasManyVariableVersions
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
end

class Parameter
  include ReferencesLanguage
  include IsUniquelyIdentifiable
  include HasOneVariableVersion
  belongs_to :procedure, polymorphic: true
end

class VariableVersion
  include ReferencesLanguage
  include IsUniquelyIdentifiable
  belongs_to :versionable, polymorphic: true
  has_many :types, class_name: 'Type', inverse_of: :variables_versions
end
