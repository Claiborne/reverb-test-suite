require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'concept_relations_json.rb'

### NOTE: This is hardcoded for stage only right now ####

puts delete_concept_relation

#  curl -H "content-type: application/json" -XPOST http://10.196.26.180:8000/api/recommend/recBundleFromConcept -d '{"concepts":[{"id":"Baseball","weight":1.0}]}'

=begin

describe "IDUN - Add and Delete Related Concepts" do

  def get_related_concept(idun_endpoint, concept, headers)
    begin
      RestClient.post idun_endpoint, concept, headers
    rescue => e
      raise StandardError.new(e.message+" "+@idun_endpoint)
    end
  end

  before(:all) do
    # Get idun environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/idun.yml"
    @idun_environment = "http://#{ConfigPath.new.options['baseurl']}:8000"

    # Get insights environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/insights.yml"
    @insights_environment = "http://#{ConfigPath.new.options['baseurl']}"
    @insights_auth = ConfigPath.new.options['auth'].to_s

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}
    @insights_headers = {:content_type => 'application/json', :Authorization => "Basic #@insights_auth"}

    @idun_endpoint = "#@idun_environment/api/recommend/recBundleFromConcept"
    @get_baseball = {"concepts"=>[{"id"=>"Baseball","weight"=>1.0}]}.to_json
  end

  it 'get intereset relation assert sort desc weight w/ no \'Jackie Robinson\'' do
    list_of_concepts = []
    list_of_concepts_weights = []
    res = get_related_concept @idun_endpoint, @get_baseball, @headers
    data = JSON.parse res
    data['concepts'].each do |concept|
      list_of_concepts << concept['id']
      list_of_concepts_weights << concept['weight']
    end
    list_of_concepts.include?('Jackie Robinson').should be_false
    list_of_concepts_weights.should == list_of_concepts_weights.sort.reverse
  end

  it 'add \'Jackie Robinson\' as intereset relation' do
    url = "https://#@insights_environment/proxy/concepts-service/api/concepts/updateCuratedRelated?concept=Baseball"
    begin
      RestClient.post url, concept, @headers
    rescue => e
      raise StandardError.new(e.message+" "+@idun_endpoint)
    end
  end

  it 'get intereset relation assert \'Jackie Robinson\'' do

  end

  it 'delete \'Jackie Robinson\' as intereset relation' do

  end

  it 'get intereset relation assert no \'Jackie Robinson\'' do

  end
=end
