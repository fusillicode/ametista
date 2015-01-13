require_relative '../schema'
require_relative 'language_querier'

class Querier

  extend Initializer
  initialize_with ({
    language_querier: LanguageQuerier.new
  })

  # TODO, se la situazione del Querier rimane questa, ovvero quella di un oggetto che forwarda al LanguageQuerier
  # si può pensare di usare Forwardable
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif language_querier.respond_to? method_name
      language_querier.public_send method_name, *args, &block
    end
  end

end
