#!/usr/bin/env ruby

require_relative "./Model.rb"

model = Model.new
model.build

IFunction.all.to_a.each do |function|
  puts function.unique_name
  puts function.name
  puts function.i_namespace
  puts function.statements
  puts function.return_statements
end

INamespace.all.to_a.each do |namespace|
  puts namespace.name
  # puts 'with parent ' + (namespace.parent_i_namespace ? namespace.parent_i_namespace.name : '')
  # puts namespace.statements
  # p namespace.i_functions
  # p namespace.i_functions.count
  # p namespace.statements.content unless namespace.statements.nil?
end
