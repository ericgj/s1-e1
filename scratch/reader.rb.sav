# this is an example usage of twitter/json_stream to read statuses
#
# interestingly, it seems basic auth still works against the Streaming API?
#

require 'rubygems'
require 'twitter/json_stream'
require 'json'

def parse(text)
  JSON.parse(text)
end

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path => '/1/statuses/filter.json',
    :auth => '',
    #:oauth => {
    #           :consumer_key    => "",
    #           :consumer_secret => "",
    #           :access_key      => "",
    #           :access_secret   => ""
    #          },                    
    :method => 'POST',
    :content => 'track=@ericgj_rmu'
  )
    
  stream.each_item do |item|
    $stdout.print "item:\n#{JSON.pretty_generate(parse(item))}\n"
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
  
  trap('INT') {
    stream.stop
    EventMachine.stop if EventMachine.reactor_running?
  }
}
puts "The event loop has ended"