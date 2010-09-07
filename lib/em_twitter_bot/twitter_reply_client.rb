#TODO

module Twitter
class ReplyClient

  def send_direct_message(text)
    $stdout.print "Sending direct message:\n  #{text}\n"
    $stdout.flush
  end
  
  def initialize(reply_to, opts = {})
  end
  
end
end
