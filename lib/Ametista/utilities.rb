module Initializer
  require 'active_support'
  def initialize_with default_attributes
    attr_accessor *default_attributes.keys
    define_method :default_attributes do
      default_attributes
    end
    include InstanceMethods
  end
  module InstanceMethods
    def initialize args = {}
      set_instance_variables(
        superclass(:default_attributes, {})
        .deep_merge(default_attributes)
        .deep_merge(args)
      )
    end
    def set_instance_variables attributes
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
    def superclass method, default_return_value
      self.class.superclass.instance_method(method).bind(self).call rescue default_return_value
    end
  end
end

module UniqueMapper
  def map_unique unique_id, &block
    self.map(&block).compact.uniq{ |x| x.send("#{unique_id}") }
  end
end

class Array
  include UniqueMapper
  def first_and_last
    return self.first, self.last
  end
end

module Nokogiri
  module XML
    class NodeSet
      include UniqueMapper
    end
  end
end
