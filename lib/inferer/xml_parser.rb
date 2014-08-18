require_relative 'utilities'
require 'nokogiri'

class XMLParser

  extend Initializer
  initialize_with ({
    output_class: Nokogiri::XML::Document
  })

  def parse ast
    Nokogiri::XML(ast)
  end

end
