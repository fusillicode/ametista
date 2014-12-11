require "mongoid"
include EnforceAvailableLocales

module HasAUniqueName
  def self.included base
    base.include Mongoid::Document
    base.field :unique_name, type: String
    base.index({ unique_name: 1 }, { unique: true, drop_dups: true })
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module HasAName
  def self.included base
    base.include Mongoid::Document
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
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
    base.has_many :global_variables, class_name: 'GlobalVariable', as: :global_scope
  end
end

module ContainsLocalVariables
  def self.included base
    base.include Mongoid::Document
    base.has_many :local_variables, class_name: 'LocalVariable', as: :local_scope
  end
end

module IsAProcedure
  def self.included base
    base.include ReferencesLanguage
    base.include HasAName
    base.include ContainsLocalVariables
    base.embeds_one :content, class_name: 'Content', as: :container
    base.has_many :parameters, class_name: 'Parameter', as: :procedure
  end
end

# I need these "abstract" class to handle the n-n relation between them
# (can't handle the relation with polymorfic)
class Type
  include ReferencesLanguage
  include HasAName
  has_and_belongs_to_many :variables, class_name: 'Variable', inverse_of: :types
end

class Variable
  include ReferencesLanguage
  include HasAName
  has_and_belongs_to_many :types, class_name: 'Type', inverse_of: :variables
  has_many :assignements, class_name: 'Assignement', inverse_of: :variable
  # has_many :methods_invocations, class_name: 'MethodInvocation', inverse_of: :variable
end

################################################################################

class Language
  include IsSingleton
  include HasAName
  include Mongoid::Attributes::Dynamic
end

class Content
  include Mongoid::Document
  embedded_in :container, polymorphic: :true
end

class Namespace
  include ReferencesLanguage
  include HasAUniqueName
  embeds_many :contents, class_name: 'Content', as: :container
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
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
  belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
  has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
  has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
  has_many :properties, class_name: 'Property', inverse_of: :klass
  def unique_name
    "#{namespace.unique_name}#{language.namespace_separator}#{name}"
  end
end

class PrimitiveType < Type
end

# alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod
  include IsAProcedure
  belongs_to :klass, class_name: 'Klass', inverse_of: :methods
  # has_and_belongs_to_many :methods_invocations, class_name: 'MethodInvocation', inverse_of: :methods
  def unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Function
  include IsAProcedure
  belongs_to :namespace, class_name: 'Namespace', inverse_of: :functions
  def unique_name
    "#{namespace.unique_name}#{language.namespace_separator}#{name}"
  end
end

class GlobalVariable < Variable
  field :type, type: String, default: 'GLOBALS'
  belongs_to :global_scope, polymorphic: true
  after_initialize do
    self.global_scope ||= Namespace.find_or_create_by(language.global_namespace)
  end
  def unique_name
    "#{language.global_namespace['unique_name']}#{language.namespace_separator}#{type}[#{name}]"
  end
end

class LocalVariable < Variable
  belongs_to :local_scope, polymorphic: true
  def unique_name
    "#{local_scope.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Property < Variable
  field :type, type: String
  belongs_to :klass, class_name: 'Klass', inverse_of: :properties
  scope :instances_properties, ->{ where(type: language.instance_property) }
  def unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Parameter < Variable
  belongs_to :procedure, polymorphic: true
  def unique_name
    "#{procedure.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Assignement
  include ReferencesLanguage
  include HasAName
  field :name, type: String, overwrite: true, default: ->{ variable.unique_name }
  field :position, type: Array
  field :rhs, type: String
  belongs_to :variable, polymorphic: true
  def unique_name
    "#{variable.unique_name}#{language.namespace_separator}#{position}"
  end
end

# class MethodInvocation
#   include ReferencesLanguage
#   include HasAName
#   field :name, type: String, overwrite: true, default: ->{ variable.unique_name }
#   field :position, type: Array
#   belongs_to :variable, polymorphic: true
#   has_and_belongs_to_many :methods, class_name: 'KlassMethod', inverse_of: :methods_invocations
#   def unique_name
#     "#{variable.unique_name}#{language.namespace_separator}#{position}"
#   end
# end

# class FunctionInvocation
#   include ReferencesLanguage
#   include HasAName
#   field :name, type: String, overwrite: true, default: ->{ function.unique_name }
#   field :position, type: Array
#   belongs_to :function, class_name: 'Function', inverse_of: :functions_invocations
#   def unique_name
#     "#{function.unique_name}#{language.namespace_separator}#{position}"
#   end
# end
