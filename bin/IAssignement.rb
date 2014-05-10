require "ohm"

class IAssignement < Ohm::Model

  reference :lhs, :IVariable
  attribute :rhs

end
