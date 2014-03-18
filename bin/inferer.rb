#!/usr/bin/env ruby

require "redis"
require "nokogiri"
require "ohm"

class Event < Ohm::Model
  attribute :name
  reference :venue, :Venue
  set :participants, :Person
  counter :votes

  index :name
end

class Venue < Ohm::Model
  attribute :name
  collection :events, :Event
end

class Person < Ohm::Model
  attribute :name
end

Ohm.connect :url => "redis://127.0.0.1:6379"

# xml = Nokogiri.parse redis.get './test_codebase/classes/log/AbstractLogger.php'
# xml.xpath('//node:*').first

event = Event.create :name => "Ohm Worldwide Conference 2031"
event = Event[3]
p Event.all
