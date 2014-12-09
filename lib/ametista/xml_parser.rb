require 'nokogiri'

class XMLParser

  def parse ast
    Nokogiri::XML(ast) { |config|
      config.noblanks
    }.remove_namespaces!
  end

end
