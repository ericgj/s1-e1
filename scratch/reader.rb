# this is an example usage of twitter/json_stream to read statuses
# note stream.each_item does not parse the json
#
require 'rubygems'
require 'twitter/json_stream'

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path => '/1/statuses/filter.json',
    :auth => 'LOGIN:PASSWORD',
    :method => 'POST',
    :content => 'track=basketball,football,baseball,footy,soccer'
  )
    
  stream.each_item do |item|
    $stdout.print "item: #{item}\n"
    $stdout.flush
  end
  
  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end
  
  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end
  
  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
  
  trap('TERM') {
    stream.stop
    EventMachine.stop if EventMachine.reactor_running?
  }
}
puts "The event loop has ended"