require "redis"
require "nokogiri"
require_relative "IType"
require_relative "IVariable"
require_relative "INamespace"

class Model

  attr_reader :redis
  attr_accessor :current_i_namespace
  attr_accessor :current_i_function
  attr_accessor :current_i_class
  attr_accessor :current_i_method

  def initialize
    build_types
    build_global_variables
    @magic_constants = ['Scalar_LineConst', 'Scalar_FileConst',
                        'Scalar_DirConst', 'Scalar_FuncConst',
                        'Scalar_ClassConst', 'Scalar_TraitConst',
                        'Scalar_MethodConst', 'Scalar_NSConst']
    @redis = Redis.new
  end

  def build_types
    ['bool', 'int', 'double', 'string', 'array', 'null'].each do |type|
      IType.create(:unique_name => type)
    end
  end

  def build_global_variables
    ['GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER', 'FILES', '_SESSION',
     '_ENV', '_COOKIE'].each do |global_variable|
      IVariable.create(:unique_name => global_variable,
                       :type => 'global')
    end
  end

  def build
    while ast = parse(asts)
      INamespace.build(ast, self)
    end
  end

  def asts
    redis.brpoplpush('xmls_asts', 'done', :timeout => 0)
  end

  def parse(ast)
    Nokogiri::XML(ast) unless last_ast?(ast)
  end

  def last_ast?(ast)
    ast == "THAT'S ALL FOLKS!"
  end

  # ##############################################################################

  # def self.get_type(variable)
  #   self.get_type_hint(variable) or self.get_default_value_type(variable)
  # end

  # def self.get_type_hint(variable)
  #   # L'ultimo elemento del nome esteso del parametro che può essere eventualmente il type hint per il parametro
  #   type_hint = variable.xpath('./subNode:type//subNode:parts//scalar:string').last

  #   # type_hint può essere Nil
  #   type_hint.text if type_hint and @scalar_types.include?(type_hint.text)
  # end

  # def self.get_default_value_type(variable)

  #   default_value = variable.xpath('./subNode:default/*[1]').first.name

  #   if default_value === 'Scalar_DNumber'
  #     'double'
  #   elsif default_value === 'Scalar_LNumber'
  #     'int'
  #   elsif default_value === 'Expr_ConstFetch'
  #     'bool'
  #   elsif default_value === 'Expr_Array'
  #     'array'
  #   elsif default_value === 'Scalar_String' or @magic_constants.include?(default_value)
  #     'string'
  #   else
  #     '✘'
  #   end

  # end

end
