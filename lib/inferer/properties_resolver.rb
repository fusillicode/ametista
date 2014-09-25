require_relative 'utilities'
require_relative 'schema'

class PropertiesResolver

  def solve
    assign_property_to_correct_klass
  end

  def assign_property_to_correct_klass
    Property.all.each do |property|
      p property.klass.parent_klass.properties if property.klass.parent_klass
      # property.update_attributes(
      #   klass: belonging_klass(property)
      # )
    end
  end

  def belonging_klass property

  end

end
