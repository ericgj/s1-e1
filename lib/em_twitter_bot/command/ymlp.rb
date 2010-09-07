require 'json'

module Command
class YMLP < Command::Base

  COMMAND_MAP = {
    'cntc.unsub?' => 'Contacts.GetUnsubscribed'
  }
  
  build_uri do |c| 
    "http://www.ymlp.com/api/#{COMMAND_MAP[c.text]}"
  end
  
  build_query do |c| 
    {'Key' => c.env['Key'], 
     'Username' => c.env['Username'],
     'Output' => 'JSON'
    }
  end
  
  parse_response { |http| JSON.parse(http.response) }
  
end
end