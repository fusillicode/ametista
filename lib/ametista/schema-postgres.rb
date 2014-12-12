ActiveRecord::Schema.define do

  create_table 'types', :force => true do |t|
    t.string :name, null: false
    t.belongs_to :namespace, class_name: 'Namespace', inverse_of: :klasses
    t.belongs_to :parent_klass, class_name: 'Klass', inverse_of: :child_klasses
    t.has_many :child_klasses, class_name: 'Klass', inverse_of: :parent_klass
    t.has_many :methods, class_name: 'KlassMethod', inverse_of: :klass
    t.has_many :properties, class_name: 'Property', inverse_of: :klass
    t.string  :global_scope_type
  end

  create_table 'variables_types', id: false, :force => true do |t|
    t.string :name, null: false
    t.integer :variable_id
    t.integer :type_id
  end

  create_table 'variables', :force => true do |t|
    t.string  :name, null: false
    belongs_to :procedure, polymorphic: true
  end

  create_table 'namespaces', :force => true do |t|
    t.string :name, null: false
  end

  create_table 'procedures', :force => true do |t|
    t.string :name, null: false
  end

  create_table 'assignements', :force => true do |t|
    t.string :name, null: false
    t.string :position, array: true
    t.column :rhs, :xml
    t.integer :variable_id
    t.string  :variable_type
  end

end
