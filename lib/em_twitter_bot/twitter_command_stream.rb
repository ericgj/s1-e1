
module Twitter
class CommandStream

  require 'twitter/json_stream'
  require 'json'
  
  TWITTER_TRACK_PATH = '/1/statuses/filter.json'
  TWITTER_TRACK_METHOD = 'POST'
  
  
  def command_callbacks
    @command_callbacks ||= {}
  end
      
  def each_command(*args, &blk)
    command_callbacks[args.flatten] = blk
  end
  
  alias_method :route_command, :each_command
  
  def unaddressed_command(&blk)
    @unaddressed_command_callback = blk
  end
  
  def unparseable_command(&blk)
    @unparseable_command_callback = blk
  end
  
  def unroutable_command(&blk)
    @unroutable_command_callback = blk
  end
  
  
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
      reset_state
      @json_item = JSON.parse(item)
      if reply?
        if command? 
          if command_callbacks.has_key?(command_key)
            command_callbacks[command_key].call(command, command_reply_to(opts))
          else
            @unroutable_command_callback.call(@json_item['text'], @json_item['user']['screen_name']) \
             if @unroutable_command_callback
          end
        else
          @unparseable_command_callback.call(@json_item['text'], @json_item['user']['screen_name']) \
           if @unparseable_command_callback
        end
      else
        @unaddressed_command_callback.call(@json_item['text'], @json_item['user']['screen_name']) \
          if @unaddressed_command_callback
      end
    end
   
  end
  
  protected
  
  def reset_state
    @json_item, @command, @is_reply, @is_command, @command_reply_to = nil
  end
  
  def reply?
    return nil unless @json_item
    @is_reply ||= \
      !(@json_item['in_reply_to_user_id'].nil?) && \
      !(@json_item['in_reply_to_user_id'] == @json_item['user']['id'])
  end
  
  def command?
    return nil unless @json_item
    @is_command ||= (command.size >= 3)
  end
  
  def command
    return nil unless @json_item
    @command ||= @json_item['text'].split(' ')
  end
    
  def command_key
    command[1..2]
  end
  
  def command_reply_to(opts = {})
    return nil unless @json_item
    @command_reply_to ||= Twitter::ReplyClient.new(@json_item['user'], opts)
  end
  
end
end