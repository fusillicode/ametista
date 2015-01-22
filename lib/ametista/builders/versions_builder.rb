require_relative 'builder'
require_relative '../schema'

class VersionsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: GlobalVariablesQuerier.new
  })

  def global_definition_versions global_variable, global_definition_ast
    global_definition_line = global_definition_ast.xpath('./endLine/int').text
    ancestor = global_definition_ast.xpath('./ancestor::*[self::Stmt_Function or self::Stmt_ClassMethod or self::Stmt_Namespace][1]')
    ap ancestor.xpath(".//Expr_Assign[endLine/int >= #{global_definition_line} and var/Expr_Variable/name/string[text() = '#{global_variable.name}']]")
    exit
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
