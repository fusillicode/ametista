require_relative 'utilities'
require_relative 'redis_data_source'
require_relative 'language_builder'
require_relative 'a_namespace_builder'
require_relative 'xml_parser'
require_relative 'brick'

class ModelBuilder

  extend Initializer
  initialize_with ({
    brick: Brick.new,
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
      @brick.ast = parser.parse(ast)
      top_level_builder.build(brick)
    end
  end

end
