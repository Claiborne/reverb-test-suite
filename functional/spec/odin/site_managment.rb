=begin
#require 'bunny'
require 'json'
#require 'pp'
require 'rspec'
#require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Odin Site Management API", :site_managment => true do

  before(:all) {@site_domain = 'odin-integration.helloreverb.com'}

  context 'GET /site/search' do

    it 'should...' do
      url = "http://localhost:8080/api/site/domain"
      body = {"domain"=>'odin-integration.helloreverb.com'}
      begin
        @response = RestClient.post url, body.to_json, :content_type => 'application/json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @doc = JSON.parse @response
    end
  end

end

#http http://localhost:8080/api/site/search?searchString=odin-integration.helloreverb.com
=end