class IScope
  include MongoMapper::Document
  one :scope
  belogs_to :scope
  many :assignements
  key :id, String
  key :name, String
  key :statements
end

class IProcedure < IScope
  many :paramters
  many :localal_variables
  key :return_value
end

class INamespace < IScope
  belogs_to :namespace
  many :functions
  many :classes
  many :global_variables
end

class IClass < IScope
  one :class
  belogs_to :class
  belogs_to :namespace
  many :methods
  many :properties
end

class IMethod < IProcedure
  belogs_to :class
end

class IFunction < IProcedure
  belogs_to :namespace
end

class IAssignement
  include MongoMapper::Document
  one :variable
  one :scope
  belogs_to :scope
end

class IVariable
  include MongoMapper::Document
  many :assignements
  belogs_to :scope
end

class IGlobalVariable < IVariable
  belogs_to :namespace
end

class ILocalVariable < IVariable
  belogs_to :procedure
end

class IProperty < IVariable
  belogs_to :class
end

class IParameter < IVariable
  belogs_to :procedure
end
