require_relative 'utilities'
require 'redis'

class RedisDataSource

  extend Initializer
  initialize_with ({
    redis: Redis.new,
    channel: 'xmls_asts',
    timeout: 0,
    last_data: "THAT'S ALL FOLKS!",
    data: nil
  })

  # TODO sistemare sto read che non ritorna false quando quello che leggo è uquale a last_data
  def read
    return @data = redis.brpoplpush(channel, 'done', timeout: timeout) until end_of_data?
  end

  def end_of_data?
    data == last_data
  end

end
