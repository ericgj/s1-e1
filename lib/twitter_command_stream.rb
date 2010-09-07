class TwitterCommandStream

  TWITTER_TRACK_PATH = '/1/statuses/filter.json'
  TWITTER_TRACK_METHOD = 'POST'
  
  attr_reader :unrecognized_command_callback
  
  def command_callbacks
    @command_callbacks ||= {}
  end
      
  def each_command(service = nil, &blk)
    command_callbacks[service] = blk
  end
  
  def unrecognized_command(&blk)
    @unrecognized_command_callback = blk
  end
  
  def track(user, opts = {})
  
    stream = Twitter::JSONStream.connect(
      {:path => TWITTER_TRACK_PATH,
       :method => TWITTER_TRACK_METHOD,
       :content => "track=@#{user}"
      }.merge(opts)
    )  
  
    stream.each_item do |item|
      @json_item = JSON.parse(item)
      if command?
        command_callbacks[command.service].call if \
          command_callbacks.has_key?(command.service)
      else
        unrecognized_command_callback.call if
          unrecognized_command_callback
      end
    end
    
  end
  
  protected
  
  def command?
    return nil unless @json_item
    @is_command ||= f(@json_item)  #TODO
  end
  
  def command
    return nil unless @json_item
    @command ||= g(@json_item)    #TODO
  end
    
end