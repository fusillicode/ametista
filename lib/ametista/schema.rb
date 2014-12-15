module HasUniqueName
  def self.included base
    base.field :unique_name, type: String
    base.validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module HasNameAndUniqueName
  def self.included base
    base.include DerivedUniqueName
    base.field :name, type: String
    base.validates :name, presence: true, length: { allow_blank: false }
  end
end

module DerivedUniqueName
  def self.included base
    base.field :unique_name, type: String
    base.after_initialize :init
  end
  def init
    self.unique_name = derived_unique_name
  end
end

module IsGlobalScope
  def self.included base
    base.has_many :global_variables, as: :global_scope
  end
end

module IsLocalScope
  def self.included base
    base.has_many :local_variables, as: :local_scope
  end
end

module IsProcedure
  def self.included base
    base.include HasNameAndUniqueName
    base.include IsLocalScope
    base.field :statements, type: xml
    base.has_many :parameters, as: :procedure
  end
end

class Variable
  include HasNameAndUniqueName
  has_many :types, as: :variable, through: :variable_types
  has_many :assignements, as: :variable
end

class Type
  include HasNameAndUniqueName
  has_many :variables, as: :type, through: :variable_types
end

################################################################################

class Namespace < ActiveRecord::Base
  include HasUniqueName
  field :statements, type: xml
  has_many :functions, inverse_of: :namespace
  has_many :klasses, inverse_of: :namespace
  after_initialize { extend define_scope_type }
  def define_scope_type
    is_global_namespace? ? IsGlobalScope : IsLocalScope
  end
  def is_global_namespace?
    unique_name.eql? language.global_namespace['unique_name']
  end
end

class Klass < Type
  belongs_to :namespace, inverse_of: :klasses
  belongs_to :parent_klass, class_name: 'Klass'
  has_many :child_klasses, class_name: 'Klass', foreign_key: 'parent_klass_id'
  has_many :klass_methods, inverse_of: :klass
  has_many :properties, inverse_of: :klass
  has_many :variables, through: :variables_types
  def derived_unique_name
    "#{namespace.unique_name}#{language.namespace_separator}#{name}"
  end
end

class PrimitiveType < Type
end

class VariableType < ActiveRecord::Base
  belongs_to :variable, polymorphic: true
  belongs_to :type, polymorphic: true
end

# alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod < ActiveRecord::Base
  include IsProcedure
  belongs_to :klass, inverse_of: :klass_methods
  def derived_unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Function < ActiveRecord::Base
  include IsProcedure
  belongs_to :namespace, inverse_of: :functions
  def derived_unique_name
    "#{namespace.unique_name}#{language.namespace_separator}#{name}"
  end
end

class GlobalVariable < Variable
  field :type, type: String, default: 'GLOBALS'
  belongs_to :global_scope, polymorphic: true
  after_initialize do
    self.global_scope ||= Namespace.find_or_create_by(language.global_namespace)
  end
  def derived_unique_name
    "#{language.global_namespace['unique_name']}#{language.namespace_separator}#{type}[#{name}]"
  end
end

class LocalVariable < Variable
  belongs_to :local_scope, polymorphic: true
  def derived_unique_name
    "#{local_scope.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Property < Variable
  field :type, type: String
  belongs_to :klass
  scope :instances_properties, ->{ where(type: language.instance_property) }
  def derived_unique_name
    "#{klass.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Parameter < Variable
  belongs_to :procedure, polymorphic: true
  def derived_unique_name
    "#{procedure.unique_name}#{language.namespace_separator}#{name}"
  end
end

class Assignement < ActiveRecord::Base
  include HasNameAndUniqueName
  field :position, type: Array
  field :rhs, type: xml
  belongs_to :variable, polymorphic: true
  def derived_unique_name
    "#{variable.unique_name}#{language.namespace_separator}#{position}"
  end
end
