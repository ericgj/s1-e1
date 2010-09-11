require 'rubygems'
require 'em-http-request'


EM.run {

  http = EventMachine::HttpRequest.new( 
            'http://www.ymlp.com/api/Contacts.GetUnsubscribed'
         ).get :query => {'Key' => '',
                          'Username' => ''
                         }
         
  http.callback do
    puts 'Callback fired from HttpRequest.new.get'
    puts http.response_header.status
    puts http.response_header.inspect
    puts http.response
  end
  
  http.errback do
    puts 'failed'
  end
  
  trap('INT') {
    EventMachine.stop if EventMachine.reactor_running?
  }

}