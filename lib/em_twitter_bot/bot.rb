require 'eventmachine'

Dir[File.join(File.dirname(__FILE__), 'command', '*.rb')].each do |f|
  require File.join(File.dirname(f), File.basename(f))
end

# Config and auth go here - before EM loop
TWITTER_ENV = Environment::Twitter.load
YMLP_ENV    = Environment::YMLP.load


EM.run {
  
  $stdout.print "---------------\nStarting bot...\n"
  $stdout.flush
  
  Signal.trap("INT") { puts "---------------\nExiting..."; EM.next_tick { EM.stop } }
  
  stream = Twitter::CommandStream.track(
              TWITTER_ENV['username'], 
              :auth => "#{TWITTER_ENV['username']}:#{TWITTER_ENV['password']}",
              :oauth => {
                         :consumer_key    => TWITTER_ENV['token'],
                         :consumer_secret => TWITTER_ENV['secret'],
                         :access_key      => TWITTER_ENV['atoken'],
                         :access_secret   => TWITTER_ENV['asecret']
                        }
           )
  
  $stdout.print "Listening for commands sent to #{TWITTER_ENV['username']}...\n"
  $stdout.flush
  
  stream.each_command('ymlp', 'cntc.unsub?') do |cmd, sender|
    $stdout.print "Received command on twitter stream: `#{cmd.join(' ')}`\n"
    $stdout.flush
    
    Command::YMLP.new(cmd[2], cmd[3], YMLP_ENV).run do |response|
    
      $stdout.print "Received response from YMLP: \n#{response.inspect}\n"
      $stdout.flush
 
      line1 = if response && response.is_a?(Array)
                "#{cmd[3]} : #{response.find {|p| p['EMAIL'] == cmd[3]} ? 'yes' : 'no'}"
              else
                "#{cmd[3]} : err"
              end
      line2 = "(##{cmd[1]} #{cmd[2]})"
      
      sender.send_direct_message( 
        [line1, line2].join('  ')
      )

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

