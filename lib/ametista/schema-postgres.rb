ActiveRecord::Schema.define do

  create_table 'klasses', :force => true do |t|
    t.string :name, null: false
    t.belongs_to :namespace
    t.references :parent_klass
  end

  create_table 'primitive_types', :force => true do |t|
    t.string :name, null: false
  end

  create_table 'variable_types', :force => true do |t|
    t.belongs_to :variable
    t.belongs_to :type
  end

  create_table 'global_variables', :force => true do |t|
    t.string :name, null: false
    t.string :type
    t.references :global_scope, polymorphic: true
  end

  create_table 'local_variables', :force => true do |t|
    t.string :name, null: false
    t.string :type
    t.references :local_scope, polymorphic: true
  end

  create_table 'properties', :force => true do |t|
    t.string :name, null: false
    t.string :type
    t.belongs_to :klass
  end

  create_table 'parameters', :force => true do |t|
    t.string :name, null: false
    t.string :type
    t.references :procedure, polymorphic: true
  end

  create_table 'namespaces', :force => true do |t|
    t.string :unique_name, null: false
    t.column :statements, :xml
  end

  create_table 'functions', :force => true do |t|
    t.string :name, null: false
    t.belongs_to :namespace
    t.column :statements, :xml
  end

  create_table 'klass_methods', :force => true do |t|
    t.string :name, null: false
    t.belongs_to :klass
    t.column :statements, :xml
  end

  create_table 'assignements', :force => true do |t|
    t.string :name, null: false
    t.string :position, array: true
    t.column :rhs, :xml
    t.references :variable, polymorphic: true
  end

end
