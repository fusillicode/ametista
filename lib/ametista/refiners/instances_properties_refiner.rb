require_relative '../utilities'
require_relative '../schema'

class InstancesPropertiesRefiner

  def refine
    assign_instances_properties_to_correct_klass
  end

  def assign_instances_properties_to_correct_klass
    Property.instances_properties.each do |property|
      correct_klass = correct_klass(property)
      remove_duplicates(property, correct_klass)
      property.update_attributes({
        klass: correct_klass
      })
    end
  end

  def remove_duplicates property, correct_klass
    Property.where({
      :_id.ne => property._id,
      name: property.name,
      klass: correct_klass,
      type: property.type
    }).delete
  end

  def correct_klass property
    @property_name = property.name
    find_in_klass_hierarchy(property.klass)
  end

  def find_in_klass_hierarchy klass
    @klass = klass if is_property_in?(klass)
    find_in_klass_hierarchy(klass.parent_klass) if klass.has_parent_klass?
    @klass
  end

  def is_property_in? klass
    klass.properties.where(name: @property_name).exists?
  end

end
