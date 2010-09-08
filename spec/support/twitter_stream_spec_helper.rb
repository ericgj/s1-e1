# invoke from specs like:
#
#   # binds Twitter::JSONStream.connect to passed host/port or default
#       stub_twitter_stream_client 
#
#   # starts up dummy server and pushes test messages to internal queue
#   # which will be pop'ed after receiving any request
#       start_dummy_stream_server do |server|
#         server.push example_json_message
#         server.push another_example_json_message
#       end
#
#   
module TwitterStreamSpecHelper
  
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 443

  # note this doesn't work -- instead simply call #connect with the
  # :host and :port you want to bind to
  def stub_twitter_stream_client(options = {})
    options[:host] ||= DEFAULT_HOST
    options[:port] ||= DEFAULT_PORT
    Twitter::JSONStream.should_receive(:connect).
     and_return(
        Twitter::JSONStream.connect(options)
     )
  end
  
  def start_dummy_stream_server(*args, &blk)
    args = args.flatten
    options = args.last.respond_to?(:[]) ? args.pop : {}
    args[0] ||= TwitterStreamSpecHelper::DummyStreamServer
    options[:host] ||= DEFAULT_HOST
    options[:port] ||= DEFAULT_PORT
    args << options
    EventMachine::start_server options[:host], options[:port], *args, &blk
  end
  
  
  module DummyStreamServer
  
    # we don't care what the request is, just pop the 
    # latest message from the queue if any --
    # and only do it once per connection
    def receive_data data
      unless @sent_reply
        #puts 'stream pop'
        @stream.pop { |msg| send_response msg }
        @sent_reply = true
      end
    end
        
    def initialize(*args, &blk)
      args = args.flatten
      @options = args.last.respond_to?(:[]) ? args.pop : {}
      @stream_proc = blk if block_given?
    end
    
    def post_init
      @stream = EM::Queue.new
      @stream_proc.call(self) if @stream_proc
    end
    
    def push(msg)
      #puts 'stream push'
      @stream.push(msg.is_a?(String) ? msg : JSON.dump(msg))
    end

    protected
    
    def send_response msg
      data = []
      data << "HTTP/1.1 200 OK"
      data << "Content-type: application/json"
      data << "\n\r"
      
      send_data (data.join("\n\r") + msg)
    end
    
  end
  
end

