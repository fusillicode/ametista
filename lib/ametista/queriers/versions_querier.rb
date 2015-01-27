require_relative 'querier'

class VersionsQuerier < Querier

  def global_definition_versions variable_name, ast
    scope(ast).xpath("#{global_variable_versions(end_line(ast), variable_name)}")
  end

  def global_variable_versions line, variable_name
    "(#{global_variable_versions_after_global_definition_line(line, variable_name)} |
      #{global_variable_versions_on_same_global_definition_line(line, variable_name)})"
  end

  def global_variable_versions_after_global_definition_line line, variable_name
    ".//Expr_Assign[#{after_line(line)} and #{with_same_variable_name(variable_name)}]"
  end

  def global_variable_versions_on_same_global_definition_line line, variable_name
    ".//Expr_Assign[#{same_line(line)} and #{with_same_variable_name(variable_name)} and #{after_global_definition}]"
  end

  def after_line line
    "endLine/int > #{line}"
  end

  def same_line line
    "endLine/int = #{line}"
  end

  def with_same_variable_name variable_name
    "var/Expr_Variable/name/string[text() = '#{variable_name}']"
  end

  def after_global_definition
    'preceding-sibling::*[self::Stmt_Global]'
  end

  def defined_constant_rhs ast
    ast.xpath('./args/array/Arg[2]/value/*[1]')
  end

  # def defined_constant_rhs ast
  #   ast.xpath('./args/array/*Arg[3]/value')
  # end

end
