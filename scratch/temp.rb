require 'rubygems'
require File.join(File.dirname(__FILE__), '../lib/em_twitter_bot', 'environment')

class EchoTweet

  require 'twitter/json_stream'
  require 'json'
  
  TWITTER_TRACK_PATH = '/1/statuses/filter.json'
  TWITTER_TRACK_METHOD = 'POST'
  
  def self.track(user, opts = {})
    new(user, opts)
  end
  
  def initialize(user, opts = {})
    stream = Twitter::JSONStream.connect(
      {:path => TWITTER_TRACK_PATH,
       :method => TWITTER_TRACK_METHOD,
       :content => "track=@#{user}"
      }.merge(opts)
    )  
  
    stream.each_item do |item|
      $stdout.print JSON.pretty_generate(JSON.parse(item))
      $stdout.flush
    end
  
  end
  
end

TWITTER_ENV = Environment::Twitter.load
puts "#{TWITTER_ENV['username']}:#{TWITTER_ENV['password']}"

EM.run {
  
  Signal.trap('INT') { EM.stop }
  
  puts "listening..."
  
  stream = EchoTweet.track(
              TWITTER_ENV['username'], 
              :auth => "#{TWITTER_ENV['username']}:#{TWITTER_ENV['password']}",
              :oauth => {
                         :consumer_key    => TWITTER_ENV['token'],
                         :consumer_secret => TWITTER_ENV['secret'],
                         :access_key      => TWITTER_ENV['atoken'],
                         :access_secret   => TWITTER_ENV['asecret']
                        }
           )

}