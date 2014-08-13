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
