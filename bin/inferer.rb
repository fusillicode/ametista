#!/usr/bin/env ruby

require "redis"
require "nokogiri"

redis = Redis.new

xml = Ox.parse redis.get './test_codebase/classes/log/AbstractLogger.php'
p xml.nodes[0]
