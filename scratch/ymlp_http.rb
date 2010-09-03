require 'rubygems'
require 'eventmachine'


EM.run {

  conn = EM::Protocols::HttpClient2.connect( 
            :host => 'ymlp.com',
            :port => 80
         )
         
  EM.next_tick { 

    http2 = conn.get(
      '/api/Contacts.GetUnsubscribed?Key=NNGAEPGKUKG2GNHWWJPK&Username=ericgj_rmu'
    )
    
    http2.callback do |response|
      puts 'Callback fired from HttpClient2.get'
      puts response.status
      puts response.headers
      puts response.content
    end
    
  }
  
  trap('INT') {
    EventMachine.stop if EventMachine.reactor_running?
  }

}