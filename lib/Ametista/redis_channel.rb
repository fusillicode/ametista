require_relative 'utilities'
require 'redis'

class RedisChannel

  extend Initializer
  initialize_with ({
    redis: Redis.new,
    channel: 'xmls_asts',
    timeout: 0,
    last_data: "THAT'S ALL FOLKS!",
    data: nil
  })

  def read
    fetch_data
    return @data unless end_of_data?
  end

  def fetch_data
    @data = redis.brpoplpush(channel, 'done', timeout: timeout)
  end

  def end_of_data?
    data == last_data
  end

end
