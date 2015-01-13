require 'nokogiri'

class XmlParser

  def parse ast
    Nokogiri::XML(ast) { |config|
      config.noblanks
    }.remove_namespaces!
  end

end
