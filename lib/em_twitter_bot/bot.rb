require 'rubygems'
require 'eventmachine'

Dir[File.join(File.dirname(__FILE__), 'command', '*.rb')].each do |f|
  require File.join(File.dirname(f), File.basename(f))
end

# TODO config and auth go here - before EM loop

def bot_user
  'ericgj_rmu'
end

def bot_auth
#  { :oauth => {
#               :consumer_key    => "",
#               :consumer_secret => "",
#               :access_key      => "",
#               :access_secret   => ""
#              }
#  }
  { :auth => ''}
end

def ymlp_env
  { 'Username' => 'ericgj_rmu',
    'Key' => ''
  }
end

EM.run {

  stream = Twitter::CommandStream.track(bot_user, bot_auth)
  
  stream.each_command('ymlp', 'cntc.unsub?') do |cmd, sender|
    $stdout.print "Received command on twitter stream: `#{cmd.join(' ')}`\n"
    $stdout.flush
    
    Command::YMLP.new(cmd[2], cmd[3], ymlp_env).run do |response|
    
      $stdout.print "Received response from YMLP: \n#{response.inspect}\n"
      $stdout.flush
 
      if response && response.is_a?(Array)
        sender.send_direct_message( 
          ( cmd[1..3] + 
            [':', (response.find {|p| p['EMAIL'] == cmd[3]} ? 'yes' : 'no') ]
          ).join(' ')
        )
      end
      
    end
  end
  
  stream.unaddressed_command do |raw, user|
    $stdout.print "Received unaddressed command (or command from the bot itself) from @#{user}: `#{raw}`\n"
    $stdout.flush
  end
  
  stream.unparseable_command do |raw, user|
    $stdout.print "Received unparseable command from @#{user}: `#{raw}`\n"
    $stdout.flush
  end
  
  stream.unroutable_command do |raw, user|
    $stdout.print "Received unroutable command from @#{user}: `#{raw}`\n"
    $stdout.flush
  end
  
}

