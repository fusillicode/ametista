class IScope
  include MongoMapper::Document
  has_one :child_scope, class_name: 'IScope', inverse_of: :parent_scope
  belongs_to :parent_scope, class_name: 'IScope', inverse_of: :child_scope
  has_many :assignements, class_name: 'IAssignement', inverse_of: :parent_scope
  key :id, String
  key :name, String
  key :statements, String
end

class IProcedure < IScope
  has_many :parameters
  has_many :local_variables
  key :return_value, String
end

class INamespace < IScope
  belongs_to :namespace
  has_many :functions
  has_many :classes
  has_many :global_variables
end

class IClass < IScope
  has_one :class
  belongs_to :class
  belongs_to :namespace
  has_many :methods
  has_many :properties
end

class IMethod < IProcedure
  belongs_to :class
end

class IFunction < IProcedure
  belongs_to :namespace
end

class IAssignement
  include MongoMapper::Document
  has_one :variable
  belongs_to :parent_scope, class_name: 'IScope', inverse_of: :assignements
end

class IVariable
  include MongoMapper::Document
  has_many :assignements
  belongs_to :scope
end

class IGlobalVariable < IVariable
  belongs_to :namespace
end

class ILocalVariable < IVariable
  belongs_to :procedure
end

class IProperty < IVariable
  belongs_to :class
end

class IParameter < IVariable
  belongs_to :procedure
end
