require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'rest_client'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - create one workflow via HTTP", :http_submit => true do

  before(:all) do
    
    tunnel_odin
    tunnel_odin_bunny

    $counter = 0
    @timeout = 60

    http_submit_url = "http://localhost:8080/api/corpus/submitUri"
    @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/http_submit/http_submit_1.html'
    @body = [{
      "url" => @url_submitted,
      "source" => "ReverbTestSuite"
    }].to_json

    response = RestClient.post http_submit_url, @body, :content_type => 'application/json', :accept => 'json'
    @data = JSON.parse response

  end

  context 'HTTP submission' do
    it 'should be successful' do
      @data[0]['requestId'].should match(/[a-z][0-9]|-/)
      @data[0]['url'].should == @url_submitted
    end
  end

  context 'Doc rendering', :doc_render => true do

    before(:all) do

      sleep 2

      tunnel_odin

      # get doc id
      5.times do 
        doc_status_url = "http://localhost:8080/api/ingestion/status?url=#@url_submitted"
        r = RestClient.get doc_status_url, :content_type => 'application/json', :accept => 'json'
        @doc_id = JSON.parse(r)['activities'].to_s.match(/docId\\":[0-9]{0,}/).to_s.match(/[0-9]{1,}/).to_s
        break if @doc_id.length > 0
        sleep 6
      end

      url = "http://localhost:8080/api/rendered/document/#{@doc_id}?format=json"
      begin
        @response = RestClient.get url, :content_type => 'application/json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @doc = JSON.parse @response
    end

    include_examples 'Smoke doc rendering'

  end
end 

describe "Article ingestion - create multiple workflow via one HTTP post", :http_submit => true do

  before(:all) do
    
    tunnel_odin
    tunnel_odin_bunny

    $counter = 0
    @timeout = 60

    http_submit_url = "http://localhost:8080/api/corpus/submitUri"
    @urls_submitted = OdinSpecHelper.url_array_for_http_submission

    @body = [
      {
      "url" => @urls_submitted[0],
      "source" => "ReverbTestSuite"
      },
      {
      "url" => @urls_submitted[1],
      "source" => "ReverbTestSuite"
      }
    ].to_json

    response = RestClient.post http_submit_url, @body, :content_type => 'application/json', :accept => 'json'
    @data = JSON.parse response

  end

  context 'HTTP submission' do
    it 'should be successful' do
      @data[0]['requestId'].should match(/[a-z][0-9]|-/)
      @data[0]['url'].should == @urls_submitted[0]
      @data[1]['requestId'].should match(/[a-z][0-9]|-/)
      @data[1]['url'].should == @urls_submitted[1]
    end
  end

  OdinSpecHelper.url_array_for_http_submission.each do |url_submitted|

    context 'Doc rendering', :doc_render => true do

      before(:all) do

        sleep 2

        tunnel_odin

        # get doc id
        5.times do 
          doc_status_url = "http://localhost:8080/api/ingestion/status?url=#{url_submitted}"
          r = RestClient.get doc_status_url, :content_type => 'application/json', :accept => 'json'
          @doc_id = JSON.parse(r)['activities'].to_s.match(/docId\\":[0-9]{0,}/).to_s.match(/[0-9]{1,}/).to_s
          break if @doc_id.length > 0
          sleep 6
        end

        url = "http://localhost:8080/api/rendered/document/#{@doc_id}?format=json"
        begin
          @response = RestClient.get url, :content_type => 'application/json'
        rescue => e
          raise StandardError.new(e.message+":\n"+url)
        end
        @doc = JSON.parse @response
      end

      include_examples 'Smoke doc rendering'
    end
  end
end 
