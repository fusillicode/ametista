#!/usr/bin/env ruby

require "redis"
require "nokogiri"

redis = Redis.new

xml = Nokogiri.parse redis.get './test_codebase/classes/log/AbstractLogger.php'
p xml.xpath('//node:*').first
