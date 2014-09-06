require_relative '../utilities'
require_relative '../entity_mapper'

class Querier
  extend Initializer
  initialize_with ({
    entity_mapper: EntityMapper.new
  })

  # TODO implementare anche respond_to?
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif entity_mapper.respond_to? method_name
      entity_mapper.public_send method_name, *args, &block
    else
      super
    end
  end
end
