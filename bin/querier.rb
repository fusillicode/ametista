class Querier
  extend Initializer
  initialize_with ({
    brick: Brick.new,
  })
  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      public_send method_name, *args, &block
    elsif brick.respond_to? method_name
      brick.public_send method_name, *args, &block
    else
      super
    end
  end
end
