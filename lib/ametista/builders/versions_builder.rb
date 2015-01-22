require_relative 'builder'
require_relative '../schema'

class VersionsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: GlobalVariablesQuerier.new
  })

  # ap ancestor.xpath(".//Expr_Assign[endLine/int > #{global_definition_line} and var/Expr_Variable/name/string[text() = '#{global_variable.name}']]").count
  # ap ancestor.xpath(".//Expr_Assign[endLine/int = #{global_definition_line} and preceding-sibling::*[self::Stmt_Global] and var/Expr_Variable/name/string[text() = '#{global_variable.name}']]").count

  def global_definition_versions global_variable, global_definition_ast
    global_definition_line = querier.end_line(global_definition_ast)
    global_variable_name = global_variable.name
    global_definition_ancestor = global_definition_ancestor(global_definition_ast)
    ap global_definition_ancestor.xpath("#{global_variable_versions(global_definition_line, global_variable_name)}").count
    exit
  end

  def global_variable_versions line, variable_name
    "(#{global_variable_versions_after_global_definition_line(line, variable_name)} | #{global_variable_versions_on_same_global_definition_line(line, variable_name)})"
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

  def version variable, ast
    # TODO rimuovere il check sul rhs quando Postgres consentirà l'inserimento
    # di stringhe vuote per il campo xml
    rhs = querier.rhs(ast)
    Version.create(
      variable: variable,
      position: querier.position(ast),
      rhs: (rhs.empty? ? ' ' : rhs)
    )
  end

end
