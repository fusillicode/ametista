require "mongoid"

class AScope
  include Mongoid::Document
  has_many :assignements, class_name: 'AnAssignement', inverse_of: :scope
  has_many :branches, class_name: 'ABranch', inverse_of: :scopes
end

class AnAssignement
  include Mongoid::Document
  has_one :variable, class_name: 'AVariable', inverse_of: :assignements
  belongs_to :scope, class_name: 'AScope', inverse_of: :assignements
  field :RHS, type: String
end

class ABranch < AScope
  belongs_to :scope, class_name: 'AScope', inverse_of: :branches
end

class AVariable
  include Mongoid::Document
  has_many :assignements, class_name: 'AnAssignement', inverse_of: :variable
  has_and_belongs_to_many :types, class_name: 'AType', inverse_of: :variables
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
end

class AType
  include Mongoid::Document
  has_and_belongs_to_many :variables, class_name: 'AVariable', inverse_of: :types
  field :name, type: String
  index({ name: 1 }, { unique: true })
end

class AProcedure < AScope
  has_many :parameters, class_name: 'AParameter', inverse_of: :procedure
  field :return_values, type: Array
  field :name, type: String
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
end

class ANamespace < AScope
  belongs_to :parent_namespace, class_name: 'ANamespace', inverse_of: :subnamespaces
  has_many :subnamespaces, class_name: 'ANamespace', inverse_of: :parent_namespace
  has_many :functions, class_name: 'AFunction', inverse_of: :namespace
  has_many :classes, class_name: 'AClass', inverse_of: :namespace
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  field :name, type: String
end

class AClass
  include Mongoid::Document
  belongs_to :parent_class, class_name: 'AClass', inverse_of: :child_classes
  has_many :child_classes, class_name: 'AClass', inverse_of: :parent_class
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :classes
  has_many :methods, class_name: 'AMethod', inverse_of: :class
  has_many :properties, class_name: 'AProperty', inverse_of: :class
  field :unique_name, type: String
  index({ unique_name: 1 }, { unique: true })
  field :name, type: String
end

class AMethod < AProcedure
  belongs_to :class, class_name: 'AClass', inverse_of: :methods
end

class AFunction < AProcedure
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :functions
end

class AGlobalVariable < AVariable
  belongs_to :namespace, class_name: 'ANamespace', inverse_of: :global_variables
end

class ALocalVariable < AVariable
  belongs_to :procedure, class_name: 'AProcedure', inverse_of: :local_variables
end

class AProperty < AVariable
  belongs_to :class, class_name: 'AClass', inverse_of: :properties
end

class AParameter < AVariable
  belongs_to :procedure, class_name: 'AProcedure', inverse_of: :parameters
end

module Initializer

  def initialize_with default_attributes
    attr_accessor *default_attributes.keys
    define_method :default_attributes do
      default_attributes
    end
    include InstanceMethods
  end

  module InstanceMethods

    def initialize args = {}
      attributes = default_attributes.merge(args)
      attributes.each do |name, value|
        public_send "#{name}=", value
      end
    end

    def default_attributes
      {}
    end

  end

end

class PHPLanguage

  extend Initializer
  initialize_with ({
    superglobals: [
      'GLOBALS',
      '_POST',
      '_GET',
      '_REQUEST',
      '_SERVER',
      'FALES',
      '_SESSION',
      '_ENV',
      '_COOKAE'
    ],
    types: ['bool', 'int', 'double', 'string', 'array', 'null'],
    magic_constants: [
      'Scalar_LineConst',
      'Scalar_FileConst',
      'Scalar_DirConst',
      'Scalar_FuncConst',
      'Scalar_ClassConst',
      'Scalar_TraitConst',
      'Scalar_MethodConst',
      'Scalar_NSConst'
    ]
  })

end

class MongoDaemon

  extend Initializer
  initialize_with ({
    path: './vendor/mongodb/bin/mongod',
    database: './database',
    port: 27017,
    log: './database/mongod.log',
    pid: nil
  })

  def start
    @pid = Process.spawn "#{@path} --fork --dbpath #{@database} --logpath #{@log} > /dev/null"
  end

  def stop
    Process.kill('TERM', @pid) unless @pid
  end

end

require 'redis'
require 'nokogiri'
require_relative 'ANamespaceBuilder'

class RedisDataSource

  extend Initializer
  initialize_with ({
    redis: Redis.new,
    channel: 'xmls_asts',
    timeout: 0,
    last_data: "THAT'S ALL FOLKS!",
    data: nil
  })

  def read
    return @data = redis.brpoplpush(@channel, 'done', timeout: @timeout) until end_of_data?
  end

  def end_of_data?
    @data == @last_data
  end

end

class LanguageBuilder

  extend Initializer
  initialize_with ({
    language: PHPLanguage.new
  })

  def build
    build_types
    build_superglobals
  end

  def build_types
    @language.types.each do |type|
      AType.create(name: type)
    end
  end

  def build_superglobals
    @language.superglobals.each do |superglobal|
      AGlobalVariable.create(:unique_name => superglobal)
    end
  end

end

class XMLParser

  def parse ast
    Nokogiri::XML(ast)
  end

end

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
    @language_builder.build
  end

  def start_building_loop
    while ast = @data_source.read
      @top_level_builder.build(@parser.parse(ast))
    end
  end

end

if __FILE__ == $0
  mongo_daemon = MongoDaemon.new.start
  Mongoid.load!('./mongoid.yml', :development)
  Mongoid::Config.purge!
  model_builder = ModelBuilder.new.build
  # p AType.all.count
  p ANamespace.all.count
end
