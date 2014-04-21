require "ohm"
require_relative "./Unique"

class IVariable < Ohm::Model

  extend Unique
  unique :unique_name
  attribute :unique_name

  index :name
  attribute :name

  # local, global, property
  index :scope
  attribute :scope

  attribute :value

  set :types, :IType

  # local, global
  reference :i_namespace, :INamespace
  # property
  reference :i_class, :IClass
  # local, global
  reference :i_method, :IMethod
  # local, global
  reference :i_function, :IFunction

  def local?
    scope == 'local'
  end

  def global?
    scope == 'global'
  end

  def property?
    scope == 'property'
  end

end
