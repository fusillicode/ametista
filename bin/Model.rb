require "redis"
require "nokogiri"
require_relative "IType"
require_relative "IVariable"
require_relative "INamespace"

class Model

  attr_reader :redis

  def initialize
    @global_variables = ['GLOBALS', '_POST', '_GET', '_REQUEST', '_SERVER',
                         'FILES', '_SESSION', '_ENV', '_COOKIE']
    @types = ['bool', 'int', 'double', 'string', 'array', 'null']
    @magic_constants = ['Scalar_LineConst', 'Scalar_FileConst',
                        'Scalar_DirConst', 'Scalar_FuncConst',
                        'Scalar_ClassConst', 'Scalar_TraitConst',
                        'Scalar_MethodConst', 'Scalar_NSConst']
    @redis = Redis.new
    build_types
    build_global_variables
  end

  def build_types
    @types.each do |type|
      IType.create(:unique_name => type)
    end
  end

  def build_global_variables
    @global_variables.each do |global_variable|
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

  def push_scope(key)
    redis.lpush('scope_stack', key)
  end

  def pop_scope
    redis.lpop('scope_stack')
  end

  def current_scope
    redis.lrange('scope_stack', 0, 0)[0]
  end

  def reset_scope
    redis.del('scope_stack')
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

  # def self.get_LHS(node)

  #   node = node.xpath('./*[1]')[0]

  #   case node.name
  #   when 'Expr_Variable'
  #     node.xpath('./subNode:name/scalar:string').text
  #   when 'Expr_PropertyFetch'
  #     self.get_LHS(node.xpath('./subNode:var')) + '->' + self.get_LHS(node.xpath('./subNode:name'))
  #   when 'Expr_ArrayDimFetch'
  #     self.get_LHS(node.xpath('./subNode:var')) + '[' + node.xpath('./subNode:dim//subNode:value/*').text + ']'
  #   # sia self:: che AClass::
  #   when 'Expr_StaticPropertyFetch'
  #     node.xpath('./subNode:class//subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('/') + '::' + node.xpath('./subNode:name/scalar:string')[0].text
  #   when 'Expr_Assign'
  #     self.get_LHS node.xpath('./subNode:var')
  #   when 'Expr_Concat'
  #     self.get_LHS(node.xpath('./subNode:left')) + '.' + self.get_LHS(node.xpath('./subNode:right'))
  #   when 'Scalar_String'
  #     node.xpath('./subNode:value/*').text
  #   when 'string'
  #     node.text
  #   else
  #     '✘'
  #   end

  # end

end
