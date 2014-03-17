#!/usr/bin/env ruby

require "redis"
require "json"

redis = Redis.new
redis.keys.each do |key|
  puts JSON.parse redis.get key
end


