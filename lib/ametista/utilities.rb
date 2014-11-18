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

module EnforceAvailableLocales
  # per fixare "[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message."
  I18n.config.enforce_available_locales = false
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
