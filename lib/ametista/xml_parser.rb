require 'nokogiri'

class XmlParser

  def parse ast
    Nokogiri::XML(ast) do |config|
      config.noblanks
    end.remove_namespaces!#.tap { |o| ap o.errors }
  end

end
