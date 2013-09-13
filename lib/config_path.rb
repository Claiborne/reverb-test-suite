require 'yaml'

class ConfigPath
  attr_accessor :options, :stg

  def self.config_path=(path)
    @@config_path = path
  end

  def initialize
    raise ConfigurationException, "Missing configuration file" unless File.exists?(@@config_path)
    environment = ENV['env']
    configs = YAML.load_file(@@config_path)
    @options = configs[environment]
    raise "No base URL for '#{ENV['env']}' is defined in the test's YML file" unless @options && @options['baseurl']
    
    case environment
    when 'stg'
      @stg = configs['stg']
    when 'dev'
      @stg = configs['dev']
    when 'other' # this allows testing of any base URL just by adding value to ['other']['baseurl'] in the app's YML file
      @stg = configs['other']
    end 
    
    # this is a bad hack for branch substitution
    @options['baseurl'] = @options['baseurl'].gsub(/branchname/, ENV['branch']) unless ENV['branch'] == nil    
  end
end

class BrowserConfig
  attr_accessor :options

  def self.browser_path=(path)
    @@browser_path = path
  end

  def initialize
    raise ConfigurationException, "Missing configuration file" unless File.exists?(@@browser_path)
    browser = ENV['browser']
    configs = YAML.load_file(@@browser_path)
    @options = configs[browser]
  end
end

class ConfigurationException < StandardError; end;
