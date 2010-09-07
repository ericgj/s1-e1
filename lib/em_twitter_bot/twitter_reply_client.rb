# stolen mostly from
# http://github.com/igrigorik/em-http-request/blob/master/examples/oauth-tweet.rb

# Initialize with a twitter user hash (screen_name and id for twitter user to reply to)
# and options :oauth => {
#               :consumer_key    => "...",
#               :consumer_secret => "...",
#               :access_key      => "...",
#               :access_secret   => "..."
#              }

module Twitter
class ReplyClient
  require 'em-http-request'
  require 'oauth'
  require 'oauth/client/em_http'
  
  TWITTER_URI = 
    { :new_direct_message => 'http://api.twitter.com/1/direct_messages/new.json' }
  
  
  def send_direct_message(text)
    $stdout.print "Sending direct message to #{@screen_name}:\n#{text}\n"
    $stdout.flush
    
    request = EventMachine::HttpRequest.new(
                TWITTER_URI[:new_direct_message]
              )
    http = request.post(
              :body => {'text' => text}, 
              :head => {"Content-Type" => "application/x-www-form-urlencoded"},
              :query => {'screen_name' => @screen_name, 'user_id' => @user_id}
           ) do |client|
      twitter_oauth_consumer.sign!(client, twitter_oauth_access_token)
    end

    http.callback do
      if (200..299).include? http.response_header.status.to_i
        $stdout.print "Post OK: #{http.response_header.status}\n"
      else
        $stdout.print "Post error: #{http.response_header.status}\n#{http.response}\n"
      end
      $stdout.flush
    end

    http.errback do
      $stdout.print "Failed to post: #{http.response_header.status}\n#{http.response}\n"
      $stdout.flush
    end    
  end
  
  def initialize(reply_to, opts = {})
    @screen_name = reply_to['screen_name']
    @user_id = reply_to['id']
    opts[:oauth] ||= {}
    @consumer_key = opts[:oauth][:consumer_key]
    @consumer_secret = opts[:oauth][:consumer_secret]
    @access_key = opts[:oauth][:access_key]
    @access_secret = opts[:oauth][:access_secret]
  end
  
  protected
  
  def twitter_oauth_consumer
    @twitter_oauth_consumer ||= OAuth::Consumer.new(@consumer_key, @consumer_secret, :site => "http://twitter.com")
  end

  def twitter_oauth_access_token
    @twitter_oauth_access_token ||= OAuth::AccessToken.new(twitter_oauth_consumer, @access_key, @access_secret)
  end
  
end
end
