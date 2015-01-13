require_relative '../schema'
require_relative 'language_querier'

class Querier

  extend Initializer
  initialize_with ({
    language_querier: LanguageQuerier.new
  })

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif language_querier.respond_to? method_name
      language_querier.public_send method_name, *args, &block
    end
  end

end
