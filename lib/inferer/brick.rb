require_relative 'utilities'

class Brick

  extend Initializer
  initialize_with ({
    ast: nil,
    root_unique_name: '\\',
    parent_unique_name: '\\'
  })

  def parent_name
    return parent_unique_name.split('\\').last
  end

  def parent_as_root
    parent_unique_name = root_unique_name
  end

end