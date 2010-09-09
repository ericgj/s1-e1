require 'eventmachine'
require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '../lib/em_twitter_bot/twitter_command_stream')

describe Twitter::CommandStream, ' callbacks' do
  include TwitterSpecHelper
  include TwitterStreamSpecHelper
  
  let :dummy_options do
    { :host => 'localhost', :port => 443 }
  end
  
  let :tweet_mention do
    tweet_hash({ 'text' => 'this only mentions @joe',
                 'in_reply_to_user_id' => nil,
                 'in_reply_to_screen_name' => nil,
                 'user' => user_hash({'id' => 999999, 'screen_name' => 'joe'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  let :tweet_self do
    tweet_hash({ 'text' => '@joe message to self',
                 'in_reply_to_user_id' => 999999,
                 'in_reply_to_screen_name' => 'joe',
                 'user' => user_hash({'id' => 999999, 'screen_name' => 'joe'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  let :tweet_no_command do
    tweet_hash({ 'text' => '@joe',
                 'in_reply_to_user_id' => 999999,
                 'in_reply_to_screen_name' => 'joe',
                 'user' => user_hash({'id' => 888888, 'screen_name' => 'dave'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  let :tweet_two_words do
    tweet_hash({ 'text' => '@joe what',
                 'in_reply_to_user_id' => 999999,
                 'in_reply_to_screen_name' => 'joe',
                 'user' => user_hash({'id' => 888888, 'screen_name' => 'dave'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  let :tweet_unknown_command do
    tweet_hash({ 'text' => '@joe unknown command',
                 'in_reply_to_user_id' => 999999,
                 'in_reply_to_screen_name' => 'joe',
                 'user' => user_hash({'id' => 888888, 'screen_name' => 'dave'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  let :tweet_valid_command do
    tweet_hash({ 'text' => '@joe valid command',
                 'in_reply_to_user_id' => 999999,
                 'in_reply_to_screen_name' => 'joe',
                 'user' => user_hash({'id' => 888888, 'screen_name' => 'dave'}),
                 'entities' => entities_hash({'user_mentions' => [ user_mentions_hash({'id' => 999999, 'screen_name' => 'joe'}) ] })
               })
  end
  
  
  #  Note each of these cases works assuming that the callbacks
  #  will be fired within 1 second (before the event loop stops).
  #
  #  A better way of testing eventmachine code is outlined 
  #  by Amman Gupta here, basically to run EM within a thread,
  #  (sequentially) pause it, and wake it up within whatever asynchronous
  #  callback function you want to test the state within:
  #
  #  http://groups.google.com/group/eventmachine/browse_thread/thread/a7afcd2ceafcfcad/4ae54190ed1f8daa?lnk=gst&q=testing&pli=1
  #
  it 'should throw unaddressed command if tweet is only a mention' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_mention
      end
      
      unaddressed_commands = EM::Queue.new
      unaddressed_commands.should_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)
      stream.unaddressed_command do |raw, user|
        #puts 'got here'
        unaddressed_commands.push([raw, user])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
    
  end
  
  it 'should throw unaddressed command if tweet is from the same address as the bot itself' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_self
      end
      
      unaddressed_commands = EM::Queue.new
      unaddressed_commands.should_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)
      stream.unaddressed_command do |raw, user|
        #puts 'got here'
        unaddressed_commands.push([raw, user])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
  end
  
  it 'should throw unparseable command if tweet only contains the bot address' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_no_command
      end
      
      unparseable_commands = EM::Queue.new
      unparseable_commands.should_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)
      stream.unparseable_command do |raw, user|
        #puts 'got here'
        unparseable_commands.push([raw, user])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
  end
  
  it 'should throw unparseable command if tweet is two words long' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_two_words
      end
      
      unparseable_commands = EM::Queue.new
      unparseable_commands.should_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)
      stream.unparseable_command do |raw, user|
        #puts 'got here'
        unparseable_commands.push([raw, user])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
  end
  
  it 'should throw unroutable command if tweet elements 1-2 dont match elements specified for any each_command' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_unknown_command
      end
      
      unroutable_commands = EM::Queue.new
      unroutable_commands.should_receive(:push)
      
      routed_commands = EM::Queue.new
      routed_commands.should_not_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)

      stream.unroutable_command do |raw, user|
        unroutable_commands.push([raw, user])
      end
      
      stream.each_command('valid', 'command') do |cmd, reply_to|
        routed_commands.push([cmd, reply_to])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
  end
  
  
  it 'should route command if tweet elements 1-2 match elements specified for an each_command' do
    EM.run do
      start_dummy_stream_server(dummy_options) do |server|
        server.push tweet_valid_command
      end
      
      Twitter::ReplyClient = mock.as_null_object
      
      unroutable_commands = EM::Queue.new
      unroutable_commands.should_not_receive(:push)
      
      routed_commands = EM::Queue.new
      routed_commands.should_receive(:push)
      
      stream = Twitter::CommandStream.track('joe', dummy_options)

      stream.unroutable_command do |raw, user|
        unroutable_commands.push([raw, user])
      end
      
      stream.each_command('valid', 'command') do |cmd, reply_to|
        routed_commands.push([cmd, reply_to])
      end
      
      EM.add_timer(1) do
        EM.stop
      end
    end
  end
  
end
