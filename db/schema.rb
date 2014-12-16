ActiveRecord::Schema.define do

  create_table 'types', :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.belongs_to :namespace
    t.references :parent_klass
  end

  create_table 'variable_types', :force => true do |t|
    t.belongs_to :variable
    t.belongs_to :type
  end

  create_table 'variables', :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.string :type
    t.references :scope, polymorphic: true
    t.belongs_to :klass
    t.belongs_to :procedure
  end

  create_table 'namespaces', :force => true do |t|
    t.string :unique_name, null: false
    t.xml :statements
  end

  create_table 'functions', :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.belongs_to :namespace
    t.xml :statements
  end

  create_table 'klass_methods', :force => true do |t|
    t.string :name, null: false
    t.string :unique_name
    t.belongs_to :klass
    t.xml :statements
  end

  create_table 'assignements', :force => true do |t|
    t.string :name, null: false
    t.string :unique_name, null: false
    t.string :position, array: true
    t.xml :rhs
    t.references :variable, polymorphic: true
  end

end
