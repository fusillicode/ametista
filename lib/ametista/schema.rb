require "mongoid"
include EnforceAvailableLocales

module IsIdentifiableWithNameAndUniqueName
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.field :unique_name, type: String
    base.index({ unique_name: 1 }, { unique: true, drop_dups: true })
    base.validates :name, presence: true, length: { allow_blank: false }
    base.validates :unique_name, presence: true, length: { allow_blank: false }
    base.validate :enforce_uniqueness, if: ->{
      self.class.where(
        :_id.ne => self._id,
        unique_name: self.unique_name,
      ).exists?
    }
  end
  # TODO definire una specifica eccezione da sollevare...
  def enforce_uniqueness
    raise "A #{self.class} with unique_name #{self.unique_name} has already been registered."
  end
end

module ReferencesLanguage
  def self.included base
    base.include Mongoid::Document
    base.belongs_to :language, class_name: 'Language'
    base.after_initialize do
      reference_language
    end
    base.extend ClassMethods
  end
  module ClassMethods
    def language
      @language ||= Language.first()
    end
  end
  def reference_language
    self.language ||= Language.first()
  end
end

module IsSingleton
  def self.included base
    base.include Mongoid::Document
    base.validate :enforce_singleton
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

module IsAProcedure
  def self.included base
    base.include ReferencesLanguage
    base.include IsIdentifiableWithNameAndUniqueName
    base.include ContainsLocalVariables
    base.field :statements, type: String
    base.has_many :parameters, as: :procedure
  end
end

# I need these "abstract" class to handle the n-n relation between them
# (can't handle the relation with polymorfic)
class Type
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  has_and_belongs_to_many :variables, class_name: 'Variable', inverse_of: :types
end

class Variable
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  has_and_belongs_to_many :types, class_name: 'Type', inverse_of: :variables
  has_many :assignements, inverse_of: :variable
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
    extend contains_variables
  end
  def contains_variables
    is_global_namespace? ? ContainsGlobalVariables : ContainsLocalVariables
  end
  def is_global_namespace?
    unique_name.eql? language.global_namespace['unique_name']
  end
end

class Klass < Type
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :properties, class_name: 'Property', inverse_of: :klass
  def default_unique_name
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{namespace.unique_name}#{name}"
  end
end

class PrimitiveType < Type
end

# alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod
  include IsAProcedure
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :klass, class_name: 'Klass', inverse_of: :methods
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Function
  include IsAProcedure
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :functions
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{namespace.unique_name}#{language.namespace_separator}#{name}"
  end
end

class GlobalVariable < Variable
  field :type, type: String, default: 'GLOBALS'
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :global_scope, polymorphic: true
  after_initialize do
    self.global_scope ||= Namespace.find_or_create_by(language.global_namespace)
  end
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{language.global_namespace['unique_name']}#{language.namespace_separator}#{type}[#{name}]"
  end
end

class LocalVariable < Variable
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :local_scope, polymorphic: true
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{local_scope.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Property < Variable
  field :type, type: String
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
  validate :enforce_uniqueness, if: ->{
    self.class.where(
      :_id.ne => self._id,
      unique_name: self.unique_name,
      type: self.type
    ).exists?
  }
  scope :instances_properties, ->{ where(type: language.instance_property) }
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Parameter < Variable
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  belongs_to :procedure, polymorphic: true
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{procedure.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Assignement
  include ReferencesLanguage
  include IsIdentifiableWithNameAndUniqueName
  field :unique_name, type: String, overwrite: true, default: ->{ default_unique_name }
  field :name, type: String, overwrite: true, default: ->{ variable.unique_name }
  field :position, type: Array
  field :rhs, type: String
  belongs_to :variable, polymorphic: true
  def default_unique_name
    reference_language
    unique_name || custom_unique_name
  end
  def custom_unique_name
    "#{variable.unique_name}#{language.namespace_separator}#{position}"
  end
end
