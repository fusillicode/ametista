require "ohm"

module Unique
  def create atts = {}
    begin
      super
    rescue Ohm::UniqueIndexViolation => e
      self.with :unique_name, atts[:unique_name]
    end
  end
end
