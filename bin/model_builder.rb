require_relative 'initializer'
require_relative 'redis_data_source'
require_relative 'language_builder'
require_relative 'a_namespace_builder'
require_relative 'xml_parser'

class ModelBuilder

  extend Initializer
  initialize_with ({
    data_source: RedisDataSource.new,
    language_builder: LanguageBuilder.new,
    top_level_builder: ANamespaceBuilder.new,
    parser: XMLParser.new
  })

  def build
    init_build
    start_building_loop
  end

  def init_build
    language_builder.build
  end

  def start_building_loop
    while ast = data_source.read
      break if ast == "THAT'S ALL FOLKS!"
      top_level_builder.build({
        ast: parser.parse(ast)
      })
    end
  end

end
