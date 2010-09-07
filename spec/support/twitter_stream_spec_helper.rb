# invoke from specs like:
#
#   stub_twitter_stream           # stubs client and invokes dummy server
#   stub_twitter_stream_client    # stubs just the client, server invoked in spec
#   start_dummy_stream_server     # invokes the dummy server
#
#   dummy_stream_message          # 'bounce' a message from the dummy server

module TwitterStreamSpecHelper
  
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 443
  DEFAULT_SERVER_PORT = 444
  
  def stub_twitter_stream(handler = nil, options = {})
    stub_twitter_stream_client(options)
    start_dummy_stream_server(handler, options)
  end
  
  def stub_twitter_stream_client(options = {})
    host = options[:host] || DEFAULT_HOST
    port = options[:port] || DEFAULT_PORT
    Twitter::JSONStream.should_receive(:connect).
     and_return(
        Twitter::JSONStream.connect(:host => host, :port => port)
     )
  end
  
  def dummy_stream_message( json, options = {} )
    host = options[:host] || DEFAULT_HOST
    server_port = options[:server_port] || DEFAULT_SERVER_PORT
    TwitterStreamSpecHelper::DummyStream.write(json, :host => host, :port => server_port)
  end
  
  def start_dummy_stream_server(handler = nil, options = {}, &blk)
    host = options[:host] || DEFAULT_HOST
    port = options[:port] || DEFAULT_PORT
    server_port = options[:server_port] || DEFAULT_SERVER_PORT
    handler ||= TwitterStreamSpecHelper::EchoServer
    EventMachine::start_server host, server_port, handler, options, blk
  end
  
  # packages and echoes a json message received on server_port to port
  #
  module EchoServer
  end
  
  # sends a json message to server_port and hangs up
  # 
  module DummyStream
  end
  
end


__END__

module Dummy
module Twitter
class JSONStream

  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 0
  MAX_LINE_LENGTH = 1024*1024
  
  def connect(host = DEFAULT_HOST, port = DEFAULT_PORT)
    connection = EventMachine.connect(host, port, self)
    connection
  end
  
  def each_item(&blk)
    @each_item_callback = blk
  end
  
  def post_init
    reset_state
  end

  def unbind
    receive_line(@buffer.flush) unless @buffer.empty?
  end
    
  def receive_data data
    begin
      @buffer.extract(data).each do |line|
        receive_line(line)
      end
    rescue Exception => e
      puts "#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t")
      close_connection
      return
    end
  end  
    
  def receive_line ln
    parse_stream_line ln
  end
  
  def parse_stream_line ln
    ln.strip!
    unless ln.empty?
      if ln[0,1] == '{'
        @each_item_callback.call(ln) if @each_item_callback
      end
    end
  end

  def reset_state
    @buffer  = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
  end
    
end
end
end