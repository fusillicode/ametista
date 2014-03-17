#!/usr/bin/env ruby

require "redis"
require "ox"

redis = Redis.new
redis.keys.each do |key|
  xml = Ox.parse redis.get key
  p xml.nodes
  exit
end


