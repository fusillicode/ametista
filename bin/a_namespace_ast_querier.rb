require_relative 'utilities'

class ANamespaceAstQuerier

  extend Initializer
  initialize_with ({
    brick: Brick.new,
  })

  def parent_name
    return brick.parent_unique_name.split('\\').last
  end

  def namespaces
    brick.ast.xpath('.//node:Stmt_Namespace')
  end

  def inline_namespaces
    brick.ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
  end

  def namespace_name
    brick.ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def namespace_unique_name
    subnamespaces = brick.ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    brick.root_unique_name + subnamespaces.map{ |subnamespace| "\\#{subnamespace.text}" }.join
  end

  def statements
    brick.ast.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end

  # le variabili assegnate
  def assignements
    brick.ast.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var')
  end

  def global_variable_value
    brick.ast.xpath('./subNode:expr')
  end

  def variable_name

    node = brick.ast.xpath('./*[1]')[0]

    case node.name
    when 'Expr_Variable'
      name = node.xpath('./subNode:name/scalar:string').text
      # non tratto le variabili di variabli (e.g. $$v)
      return false if name.nil? or name.empty?
      # le variabili plain assegnate sono comunque in GLOBALS
      return "GLOBALS[#{name}]" if name != 'GLOBALS'
      name
    when 'Expr_PropertyFetch'
      # non tratto proprietà con nomi dinamici
      return false if !var = variable_name(node.xpath('./subNode:var'))
      return false if !name = variable_name(node.xpath('./subNode:name'))
      var << '->' << name
    when 'Expr_ArrayDimFetch'
      # non tratto indici di array dinamici
      return var if !var = variable_name(node.xpath('./subNode:var'))
      dim = node.xpath('./subNode:dim/*[name() = "node:Scalar_String" or name() = "node:Scalar_LNumber"]/subNode:value/*').text
      return false if dim.nil? or dim.empty?
      var << '[' << dim << ']'
    when 'string'
      node.text
    else
      false
    end

  end

  def functions
    brick.ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
  end

  def classes
    brick.ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Class')
  end

end
