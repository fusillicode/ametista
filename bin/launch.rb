#!/usr/bin/env ruby

puts spawn('bundle exec bin/inferer.rb')
puts spawn('php bin/parse.php')

