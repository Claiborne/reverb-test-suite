require 'rspec'
require 'config_path'
require 'rest_client'
require 'nokogiri'
require 'json'
require 'open_page.rb'; include OpenPage
require 'fe_checker.rb'

%w(http https).each do |protocol|

describe "HelloReverb.com -- /share/collection/reverb/ces-2014 (#{protocol})" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/helloreverb.yml"
    @web_env = "#{protocol}://#{ConfigPath.new.options['baseurl']}"
    @doc = nokogiri_open @web_env+"/share/collection/reverb/ces-2014"
  end

  it "should return 200" do
  end

  it "should return h1 with text 'CES 2014'" do
    @doc.at_css('h1').text.should == 'CES 2014'
  end

  it "should return at least one article with title text" do
    tile = @doc.at_css("div[class='brick set'] span.titleText")
    tile.should be_true
    tile.text.strip.length.should > 0
  end

  it "should not return any broken tile images" do
    broken_images = []
    @doc.css('div.fullSet a div').count.should > 0
    @doc.css('div.fullSet a div').each do |image|
      image_url = image.attribute('style').to_s.gsub('background:url(','').gsub(/\).*/,'')
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

describe "HelloReverb.com -- /share/interest/reverb/HTML5 (#{protocol})" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/helloreverb.yml"
    @web_env = "#{protocol}://#{ConfigPath.new.options['baseurl']}"
    @doc = nokogiri_open @web_env+"/share/interest/reverb/HTML5"
  end

  it "should return 200" do
  end

  it "should return h1 with text 'HTML5'" do
    @doc.at_css('h1').text.should == 'Wrong title'
  end

  it "should return at least one article with title text" do
    tile = @doc.at_css("div[class='brick set'] span.titleText")
    tile.should be_true
    tile.text.strip.length.should > 0
  end

  it "should not return any broken tile images" do
    broken_images = []
    @doc.css('div.fullSet a div').count.should > 0
    @doc.css('div.fullSet a div').each do |image|
      image_url = image.attribute('style').to_s.gsub('background:url(','').gsub(/\).*/,'')
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

end