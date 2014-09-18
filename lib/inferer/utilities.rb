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
      set_instance_variables(default_attributes.merge(args))
    end

    def set_instance_variables attributes
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end

    def default_attributes
      {}
    end
  end
end

module PatchedAwesomePrint
  require 'awesome_print'
  ::Moped::BSON = ::BSON
end

module UniqueMapper
  def map_unique &block
    self.map(&block).uniq{ |x| x._id }
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
