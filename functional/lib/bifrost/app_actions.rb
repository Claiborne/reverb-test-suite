module AppActions

  include ReadArticle
 
  def iphone_add_interest(env, token, interest, headers={:content_type => 'application/json', :accept => 'application/json'})
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>interest},
    {"name"=>"wasEntered","value"=>interest}],"eventType"=>"iphoneAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = env+"/interests?api_key="+token
    begin
      response = RestClient.post url, {:value=>interest,:interestType=>:interest}.to_json, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 1
  end

  def ipad_add_interest(env, token, interest, headers={:content_type => 'application/json', :accept => 'application/json'})
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>interest},
    {"name"=>"wasEntered","value"=>interest}],"eventType"=>"uAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = env+"/interests?api_key="+token
    begin
      response = RestClient.post url, {:value=>interest,:interestType=>:interest}.to_json, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 1
  end

  def iphone_tap_interest(env, token, interest, headers={:content_type => 'application/json', :accept => 'application/json'})
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>interest},
    {"name"=>"rank","value"=>"0"},{"name"=>"featured","value"=>"0"}],
    "eventType"=>"iphoneTapInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1
  end

  def ipad_tap_interest(env, token, interest, headers={:content_type => 'application/json', :accept => 'application/json'})

  end

  def iphone_read_article(env, token, article, headers={:content_type => 'application/json', :accept => 'application/json'})
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = read_article_iphone Time.now, article
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = exit_article_iphone Time.now
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
  end

  def ipad_read_article(env, token, article, headers={:content_type => 'application/json', :accept => 'application/json'})
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = read_article Time.now, article
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1
    event_url = env+"/events/click?deviceId=reverb-test-suite&api_key=#{token}"
    event_body = exit_article Time.now
    begin
      response = RestClient.post event_url, event_body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
  end
end
