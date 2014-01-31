require 'rspec'
require 'config_path'
require 'rest_client'
require 'nokogiri'
require 'json'
require 'open_page.rb'; include OpenPage
require 'fe_checker.rb'

%w(http https).each do |protocol|

describe "HelloReverb.com - /share/collection/reverb/ces-2014 (#{protocol})" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/helloreverb.yml"
    @web_env = "#{protocol}://#{ConfigPath.new.options['baseurl']}"
    @clientId = ConfigPath.new.options['clientId'].to_s
    @clientSecret = ConfigPath.new.options['clientSecret'].to_s
    @doc = nokogiri_open @web_env+"/share/collection/reverb/ces-2014"

    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/bifrost.yml"
    @api_env = "https://#{ConfigPath.new.options['baseurl']}"
  end

  context "Bifrost API call" do

    it 'should return at least one tile' do
      url = "#@api_env/collections/shared/reverb/ces-2014?skip=0&limit=50&clientId=#@clientId&clientSecret=#@clientSecret"
      begin
        res = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse res
      data['tiles'].length.should > 0
    end
  
  end

  it "should return a < 400 response code" do
  end

  it "should return h1 with text 'CES 2014'" do
    @doc.at_css('h1').text.match(/CES 2014/).should be_true
  end

  it "should return at least one article with title text" do
    tile = @doc.at_css("div.fullSet span.titleText")
    tile.should be_true
    tile.text.strip.length.should > 0
  end

  it "should not return any broken tile images" do
    broken_images = []
    begin
      @doc.css('div.fullSet a div').count.should > 0
    rescue => e
      puts @doc
      raise e
    end
    @doc.css('div.fullSet a div').each do |image|
      image_url = image.attribute('style').to_s.gsub('background:url(','').gsub(/\).*/,'').gsub("'",'')
      begin
        response = RestClient.get image_url.to_s
        #response.code.should == 200
      rescue => e
        broken_images << "#{e.message} when requesting: #{image_url}"
        next
      end
    end
    broken_images.should == []
  end
end

describe "HelloReverb.com - /share/interest/reverb/HTML5 (#{protocol})" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/helloreverb.yml"
    @web_env = "#{protocol}://#{ConfigPath.new.options['baseurl']}"
    @clientId = ConfigPath.new.options['clientId'].to_s
    @clientSecret = ConfigPath.new.options['clientSecret'].to_s
    @doc = nokogiri_open @web_env+"/share/interest/reverb/HTML5"

    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/bifrost.yml"
    @api_env = "https://#{ConfigPath.new.options['baseurl']}"
  end

  context "Bifrost API call" do

    it 'should return at least one tile' do
      url = "#@api_env/interests/stream/me?interest=HTML5&skip=0&limit=50&clientId=#@clientId&clientSecret=#@clientSecret"
      begin
        res = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse res
      data['tiles'].length.should > 0
    end
  
  end

  it "should return a < 400 response code" do
  end

  it "should return h1 with text 'HTML5'" do
    @doc.at_css('h1').text.match(/HTML5/).should be_true
  end

  it "should return at least one article with title text" do
    tile = @doc.at_css("div.fullSet span.titleText")
    tile.should be_true
    tile.text.strip.length.should > 0
  end

  it "should not return any broken tile images" do
    broken_images = []
    begin
      @doc.css('div.fullSet a div').count.should > 0
    rescue => e
      puts @doc
      raise e
    end
    @doc.css('div.fullSet a div').each do |image|
      image_url = image.attribute('style').to_s.gsub('background:url(','').gsub(/\).*/,'').gsub("'",'')
      begin
        response = RestClient.get image_url
        response.code.should == 200
      rescue => e
        broken_images << "#{e.message} when requesting: #{image_url}"
        next
      end
    end
    broken_images.should == []
  end
end

end # end %w(http https) iteration