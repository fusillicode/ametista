require_relative '../schema'
require_relative 'querier'

class ModelQuerier < Querier

  extend Initializer
  initialize_with ({
    model: ActiveRecord::Base.connection
  })

  def xpath query, xml
    model.execute("select unnest(xpath('#{query}', '#{xml}'))")
  end

end
