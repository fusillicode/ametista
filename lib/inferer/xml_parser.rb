require 'nokogiri'

class XMLParser

  def parse ast
    Nokogiri::XML(ast)
  end

end
