require 'rubygems'
require 'em-http-request'

module Command
class Base

  class << self
    
    attr_reader :uri_proc, :head_proc, :query_proc, :body_proc
    
    def build_uri(&blk)
      @uri_proc = blk
    end
    
    def verb; @verb ||= :get; end
    
    def verb=(it)
      @verb = it.downcase.to_sym
    end
    
    def build_head(&blk)
      @head_proc = blk
    end
    
    def build_query(&blk)
      @query_proc = blk
    end
    
    def build_body(&blk)
      @body_proc = blk
    end
    
    def response_proc
      @response_proc ||= Proc.new {|response| response}
    end
    
    def parse_response(&blk)
      @response_proc = blk
    end
    
  end
    
  attr_reader :response_callback 
  attr_reader :text, :args, :env    # used in block passed to build_* above 
  
  def run(&blk)
    klass = self.class
    uri = klass.uri_proc.call(self) if klass.uri_proc
    
    if uri
      query = klass.query_proc.call(self) if klass.query_proc
      body = klass.body_proc.call(self) if klass.body_proc
      head = klass.head_proc.call(self) if klass.head_proc
      verb = klass.verb
      parser = klass.response_proc
      parts = {:query => query, :body => body, :head => head}.
               reject {|k, v| v.nil?}
               
      $stdout.print "Sending #{verb} request to YMLP: \n  uri: #{uri}\n  query: #{parts[:query].inspect}\n  head: #{parts[:head].inspect}\n  body: #{parts[:body].inspect}\n"
      $stdout.flush
      
      http = EventMachine::HttpRequest.new(uri).__send__(verb, parts)
      http.callback { blk.call(parser.call(http)) if block_given? }
      http.errback { $stdout.print "Failed with #{http.response_header.status}" }
    end
  end
  
  def initialize(*parts)
    parts = parts.flatten
    @env = parts.last.is_a?(Hash) ? parts.pop : {}
    @text = parts.shift
    @args = parts
  end
  
end
end