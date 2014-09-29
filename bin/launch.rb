#!/usr/bin/env ruby

puts spawn('bundle exec bin/ametista.rb')
puts spawn('php bin/parse.php')

