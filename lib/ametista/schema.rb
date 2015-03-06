require 'ancestry'

module HasNameAndUniqueName
  extend ActiveSupport::Concern
  included do
    validates :name, presence: true, length: { allow_blank: false }
    def unique_name
      name
    end
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
  include HasNameAndUniqueName
  # i tipi devono essere legati alle variabili o agli assegnamenti? Forse si può legarli ad entrambe
  # creando una classe Typeable
  has_and_belongs_to_many :types, :join_table => :variables_types
  has_many :versions, as: :versionable
end

class Type < ActiveRecord::Base
  include HasNameAndUniqueName
  has_and_belongs_to_many :variables, :join_table => :variables_types
  has_many :constants
end

class Content < ActiveRecord::Base
  belongs_to :container, polymorphic: true
  scope :namespaces_contents, ->{ where(container_type: 'Namespace') }
  scope :functions_contents, ->{ where(container_type: 'Function') }
  scope :klasses_methods_contents, ->{ where(container_type: 'KlassMethod') }
end

################################################################################

class Namespace < ActiveRecord::Base
  include HasNameAndUniqueName
  include ContainsStatements
  has_many :functions, inverse_of: :namespace
  has_many :klasses, inverse_of: :namespace
  has_many :constants, inverse_of: :scope
  after_initialize { extend define_scope_type }
  def define_scope_type
    is_global_namespace? ? IsGlobalScope : IsLocalScope
  end
  def is_global_namespace?
    unique_name.eql? Global.lang.php.global_namespace.name
  end
end

class Klass < Type
  has_ancestry
  belongs_to :namespace, inverse_of: :klasses
  has_many :klass_methods, inverse_of: :klass
  has_many :properties, inverse_of: :klass
  has_many :constants, inverse_of: :scope
  def unique_name
    "#{namespace.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class PrimitiveType < Type
end

# alias in modo da poter chiamare CustomType e Klass in maniera indifferenziata
CustomType = Klass

class KlassMethod < ActiveRecord::Base
  include IsProcedure
  belongs_to :klass, inverse_of: :klass_methods
  def unique_name
    "#{klass.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Function < ActiveRecord::Base
  include IsProcedure
  belongs_to :namespace, inverse_of: :functions
  def unique_name
    "#{namespace.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Constant < ActiveRecord::Base
  include HasNameAndUniqueName
  belongs_to :scope, polymorphic: true
  has_one :version, as: :versionable
  belongs_to :type
  after_initialize do
    self.scope ||= Namespace.find_or_create_by(
      name: Global.lang.php.global_namespace.name
    )
  end
  def unique_name
    "#{scope.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class GlobalVariable < Variable
  belongs_to :scope, polymorphic: true
  after_initialize do
    self.scope ||= Namespace.find_or_create_by(
      name: Global.lang.php.global_namespace.name
    )
    self.kind ||= Global.lang.php.superglobals.first
  end
  def unique_name
    "#{scope.unique_name}#{Global.lang.php.namespace_separator}#{kind}[#{name}]"
  end
end

class LocalVariable < Variable
  belongs_to :scope, polymorphic: true
  def unique_name
    "#{scope.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Property < Variable
  belongs_to :klass, inverse_of: :properties
  scope :instances_properties, ->{ where(kind: Global.lang.php.instance_property) }
  scope :self_property, ->{ where(kind: Global.lang.php.self_property) }
  scope :parent_property, ->{ where(kind: Global.lang.php.parent_property) }
  def unique_name
    "#{klass.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Parameter < Variable
  belongs_to :procedure, polymorphic: true
  def unique_name
    "#{procedure.unique_name}#{Global.lang.php.namespace_separator}#{name}"
  end
end

class Version < ActiveRecord::Base
  belongs_to :versionable, polymorphic: true
  def unique_name
    "#{versionable.unique_name}#{Global.lang.php.namespace_separator}#{position}"
  end
end
