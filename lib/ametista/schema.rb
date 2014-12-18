module HasUniqueName
  extend ActiveSupport::Concern
  included do
    validates :unique_name, presence: true, length: { allow_blank: false }
  end
end

module HasNameAndUniqueName
  extend ActiveSupport::Concern
  included do
    validates :name, presence: true, length: { allow_blank: false }
    after_initialize do
      self.unique_name = inferred_unique_name
    end
  end
  def inferred_unique_name
    name
  end
end

module IsGlobalScope
  extend ActiveSupport::Concern
  included do
    has_many :global_variables, as: :scope
  end
end

module IsLocalScope
  extend ActiveSupport::Concern
  included do
    has_many :local_variables, as: :scope
  end
end

module ContainsStatements
  extend ActiveSupport::Concern
  included do
    has_many :contents, as: :container
  end
end

module IsProcedure
  extend ActiveSupport::Concern
  include HasNameAndUniqueName
  include IsLocalScope
  include ContainsStatements
  included do
    has_many :parameters, as: :procedure
  end
end

class Variable < ActiveRecord::Base
  has_many :types, as: :variable, through: :variable_types
  has_many :assignements, as: :variable
end

class Type < ActiveRecord::Base
  include HasNameAndUniqueName
  has_many :variables, as: :type, through: :variable_types
end

class Content < ActiveRecord::Base
  belongs_to :container, polymorphic: true
end

################################################################################

class Namespace < ActiveRecord::Base
  include HasUniqueName
  include ContainsStatements
  has_many :functions, inverse_of: :namespace
  has_many :klasses, inverse_of: :namespace
  after_initialize { extend define_scope_type }
  def define_scope_type
    is_global_namespace? ? IsGlobalScope : IsLocalScope
  end
  def is_global_namespace?
    unique_name.eql? Global.lang.php.global_namespace['unique_name']
  end
end

class Klass < Type
  belongs_to :namespace, inverse_of: :klasses
  belongs_to :parent_klass, class_name: 'Klass'
  has_many :child_klasses, class_name: 'Klass', foreign_key: 'parent_klass_id'
  has_many :klass_methods, inverse_of: :klass
  has_many :properties, inverse_of: :klass
  def inferred_unique_name
    "#{namespace.unique_name}#{Global.lang.php.namespace_separator}#{name}"
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
  def inferred_unique_name
    "#{klass.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Function < ActiveRecord::Base
  include IsProcedure
  belongs_to :namespace, inverse_of: :functions
  def inferred_unique_name
    "#{namespace.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class GlobalVariable < Variable
  belongs_to :scope, polymorphic: true
  after_initialize do
    self.unique_name ||= 'GLOBALS'
    self.scope ||= Namespace.find_or_create_by(
      unique_name: Global.lang.php.global_namespace.unique_name
    )
  end
  def inferred_unique_name
    "#{Global.lang.php.global_namespace.unique_name}#{Global.lang.php.namespace_separator}#{type}[#{name}]"
  end
end

class LocalVariable < Variable
  belongs_to :scope, polymorphic: true
  def inferred_unique_name
    "#{scope.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Property < Variable
  belongs_to :klass, inverse_of: :properties
  scope :instances_properties, ->{ where(type: Global.lang.php.instance_property) }
  def inferred_unique_name
    "#{klass.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Parameter < Variable
  belongs_to :procedure, polymorphic: true
  def inferred_unique_name
    "#{procedure.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Assignement < ActiveRecord::Base
  include HasNameAndUniqueName
  belongs_to :variable, polymorphic: true
  def inferred_unique_name
    "#{variable.unique_name}#{Global.lang.php.namespace_separator}#{position}"
  end
end
