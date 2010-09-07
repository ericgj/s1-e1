require 'forwardable'

module Environment
class Twitter
  extend Forwardable
  
  require 'yaml'
  require 'oauth'
  
  def_delegator :@config, :[]
  
  def self.load(file = '.twitter')
    new(File.join(ENV['HOME'],file)).configure
  end
  
  def initialize(to_file = nil)
    @to_file = to_file
    @config = if to_file && File.exists?(to_file)
                YAML::load(open(to_file))
              end
    @config ||= Hash.new
  end
  
  def configure
    Signal.trap("INT") { "Exiting" } 
    write_on_exit = false

    puts "Checking Twitter basic auth..."
    unless @config['username']
      print "> What is your Twitter screen name? "
      @config['username'] = gets.chomp
      write_on_exit = true
    end
    unless @config['password']
      print "> What is your Twitter login password? "
      @config['password'] = gets.chomp
      write_on_exit = true
    end
    
    puts "Checking Twitter consumer..."
    unless @config['token']
      print "> What was the consumer token twitter provided you with? "
      @config['token'] = gets.chomp
      write_on_exit = true
    end
    unless @config['secret']
      print "> What was the consumer secret twitter provided you with? "
      @config['secret'] = gets.chomp
      write_on_exit = true
    end
    
    puts "Authorizing Twitter access..."
    oauth = OAuth::Consumer.new(@config['token'], @config['secret'], :site => "http://twitter.com")
    if @config['atoken'] && @config['asecret']
    else
      r = oauth.get_request_token
      puts r.token
      puts r.secret
      puts r.authorize_url
      puts "Please access the url above"
      print "> what was the PIN twitter provided you with? "
      pin = gets.chomp
      a = r.get_access_token(:oauth_verifier => pin)
      @config['atoken'] = a.token
      @config['asecret'] = a.secret
      write_on_exit = true
    end    
    
    if write_on_exit
      File.open( @to_file, 'w' ) do |out|
         YAML.dump( @config, out )
      end
    end
    self
  end
  
end


class YMLP
  extend Forwardable
  
  require 'yaml'
  
  def_delegator :@config, :[]
  
  def self.load(file = '.ymlp')
    new(File.join(ENV['HOME'],file)).configure
  end
  
  def initialize(to_file = nil)
    @to_file = to_file
    @config = if to_file && File.exists?(to_file)
                YAML::load(open(to_file))
              end
    @config ||= Hash.new
  end
  
  def configure
    Signal.trap("INT") { "Exiting" } 
    write_on_exit = false

    puts "Checking YMLP user info..."
    unless @config['username']
      print "> What is your YMLP login name? "
      @config['username'] = gets.chomp
      write_on_exit = true
    end
    unless @config['key']
      print "> What is your YMLP API key? "
      @config['key'] = gets.chomp
      write_on_exit = true
    end
        
    if write_on_exit
      File.open( @to_file, 'w' ) do |out|
         YAML.dump( @config, out )
      end
    end
    self
  end
  
end

end

