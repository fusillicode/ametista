#!/usr/bin/env ruby

require_relative "Model.rb"

model = Model.new
model.build

# IProcedure.all.to_a.each do |function|
#   puts function.unique_name
#   puts function.name
#   puts function.i_namespace
#   puts function.statements
#   puts function.return_statements
#   function.parameters.each do |parameter|
#     p parameter.name
#     p parameter.unique_name
#   end
# end

# INamespace.all.to_a.each do |namespace|
#   puts namespace.name
#   puts 'with parent ' + (namespace.parent_i_namespace ? namespace.parent_i_namespace.name : '')
#   puts namespace.statements.content if namespace.statements
#   p namespace.i_functions
#   p namespace.i_functions.count
#   # p namespace.statements.content unless namespace.statements.nil?
# end


# IVariable.find(type: 'global').each do |parameter|
#   p parameter.unique_name
# end

