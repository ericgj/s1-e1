
# TODO config and auth go here - before EM loop

EventMachine::Run {

  stream = TwitterCommandStream.follow(bot_user, bot_auth)
  
  stream.each_command('ymlp') do |cmd, sender|
    Command::YMLP.new(cmd).call do |response|
      sender.send_direct_message(response)
    end
  end
  
}