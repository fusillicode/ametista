require 'nokogiri'

class XMLParser

  def parse ast
    Nokogiri::XML(ast) do |config|
      config.noblanks
    end
  end

end
