require "ohm"
require_relative "./Unique"

class IVariable < Ohm::Model

  extend Unique
  unique :unique_name
  attribute :unique_name

  index :name
  attribute :name

  # local, global, property, parameter
  index :type
  attribute :type

  attribute :value

  set :types, :IType

  # local, global
  reference :i_namespace, :INamespace
  # property
  reference :i_class, :IClass
  # local, global
  reference :i_procedure, :IProcedure

  def local?
    type == 'local'
  end

  def global?
    type == 'global'
  end

  def property?
    type == 'property'
  end

  def parameter?
    type == 'parameter'
  end

end
