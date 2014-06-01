require "ohm"
require_relative "Unique"
require_relative "IVariable"
require_relative "IProcedure"

class IClass < Ohm::Model

  extend Unique
  index :unique_name
  unique :unique_name
  attribute :unique_name

  index :name
  attribute :name

  reference :parent_i_class, :IClass
  reference :i_namespace, :INamespace

  collection :i_methods, :IProcedure, :i_class
  collection :properties, :IVariable, :i_class

  class << self

    def build(a_class, model)
      @a_class = a_class
      @model = model
      build_class
      build_parent_class
      build_properties
      build_methods
    end

    def build_class
      class_unique_name = get_unique_name
      @current_i_class = self.create(:unique_name => class_unique_name,
                                      :name => get_name,
                                      :i_namespace => INamespace.find(unique_name: @model.current_scope).first)
      @model.push_scope(class_unique_name)
    end

    def build_parent_class
      return if (parent_class_name_parts = get_parent_class_name_parts).empty?
      @current_i_class.parent_i_class = self.create(:unique_name => get_parent_class_unique_name(parent_class_name_parts),
                                                   :name => get_parent_class_name(parent_class_name_parts))
      @current_i_class.save
    end

    def build_properties
      get_one_line_properties.each do |one_line_property|

        get_properties(one_line_property).each do |property|

          property_name = get_property_name(property)

          IVariable.create(:unique_name => get_property_unique_name(property),
                           :name => get_property_name(property),
                           :type => 'property',
                           :value => get_property_value(property),
                           :i_class => @current_i_class)

        end

      end
    end

    def build_methods
      get_methods.each do |method|
        IProcedure.build(method, :i_method, @model)
      end
    end

    def get_one_line_properties
      @a_class.xpath('./subNode:stmts/scalar:array/node:Stmt_Property')
    end

    def get_properties(one_line_property)
      one_line_property.xpath('./subNode:props/scalar:array/node:Stmt_PropertyProperty')
    end

    def get_property_unique_name(property)
      property.xpath('./subNode:name/scalar:string').text
    end

    def get_property_name(property)
      property.xpath('./subNode:name/scalar:string').text
    end

    def get_property_value(property)
      property.xpath('./subNode:default')
    end

    def get_parent_class_name_parts
      @a_class.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1]
    end

    def get_parent_class_unique_name(parent_class_name_parts)
      '\\' << parent_class_name_parts[0..-1].to_a.join('\\')
    end

    def get_parent_class_name(parent_class_name_parts)
      parent_class_name_parts.last().text
    end

    def get_unique_name
      '\\' << @a_class.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    end

    def get_name
      @a_class.xpath('./subNode:name/scalar:string').text
    end

    def get_methods
      @a_class.xpath('./subNode:stmts/scalar:array/node:Stmt_ClassMethod')
    end

  end

end
