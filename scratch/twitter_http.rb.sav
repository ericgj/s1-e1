# stolen from
# http://github.com/igrigorik/em-http-request/blob/master/examples/oauth-tweet.rb

# TODO: replace overly complicated oauth library with roauth
#       which simply adds an Authorization header based on 4 keys below; 
#       see twitter-stream/lib/twitter/json_stream for example

require 'rubygems'
require 'em-http-request'
require 'oauth'

# At a minimum, require 'oauth/request_proxy/em_http_request'
# for this example, we'll use Net::HTTP like support.
require 'oauth/client/em_http'

# You need two things: an oauth consumer and an access token.
# You need to generate an access token, I suggest looking elsewhere how to do that or wait for a full tutorial.
# For a consumer key / consumer secret, signup for an app at:
# http://twitter.com/apps/new

# Edit in your details.
CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_TOKEN_SECRET = ""


def twitter_oauth_consumer
  @twitter_oauth_consumer ||= OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => "http://twitter.com")
end

def twitter_oauth_access_token
  @twitter_oauth_access_token ||= OAuth::AccessToken.new(twitter_oauth_consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
end


EM.run {

  request = EventMachine::HttpRequest.new(
              'http://api.twitter.com/1/direct_messages/new.json'
            )
  http = request.post(
            :body => {'text' => 'A private message from myself sent from em-http-request with OAuth'}, 
            :head => {"Content-Type" => "application/x-www-form-urlencoded"},
            :query => {'screen_name' => 'ericgj_rmu', 'user_id' => '186283225'}
         ) do |client|
    twitter_oauth_consumer.sign!(client, twitter_oauth_access_token)
  end

  http.callback do
    puts "Response: #{http.response} (Code: #{http.response_header.status})"
    EM.stop_event_loop
  end

  http.errback do
    puts "Failed to post"
    EM.stop_event_loop
  end

}