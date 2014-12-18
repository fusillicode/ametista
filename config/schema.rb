ActiveRecord::Schema.define(:version => 0) do

  create_table "assignements", :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.string :position, array: true, default: []
    t.xml :rhs
    t.references :variable, polymorphic: true
  end

  create_table "contents", :force => true do |t|
    t.xml :statements
    t.references :container, polymorphic: true
  end

  create_table "functions", :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.integer :namespace_id
  end

  create_table "klass_methods", :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.integer :klass_id
  end

  create_table "namespaces", :force => true do |t|
    t.string :unique_name, null: false
  end

  create_table "types", :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.integer :namespace_id
    t.references :parent_klass
  end

  create_table "variable_types", :force => true do |t|
    t.integer :variable_id
    t.integer :type_id
  end

  create_table "variables", :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.string :type
    t.references :scope, polymorphic: true
    t.integer :klass_id
    t.references :procedure, polymorphic: true
  end

end
