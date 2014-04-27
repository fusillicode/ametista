require "ohm"

class IRawContent < Ohm::Model

  attribute :content

  reference :i_namespace, :INamespace
  reference :i_procedure, :IProcedure

end
