module Initializer
  def initialize_with default_attributes
    attr_accessor *default_attributes.keys
    define_method :default_attributes do
      default_attributes
    end
    include InstanceMethods
  end

  module InstanceMethods
    def initialize args = {}
      attributes = default_attributes.merge(args)
      attributes.each do |name, value|
        public_send "#{name}=", value
      end
    end

    def default_attributes
      {}
    end
  end
end

class Array
  def first_and_last
    return self.first, self.last
  end
end

class String
  def name_from_unique_name
    return self.split('\\').last
  end
end
