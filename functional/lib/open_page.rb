module OpenPage

  def nokogiri_open(page,headers=nil)
    begin
      nok_doc = Nokogiri::HTML(RestClient.get(page,headers))
    rescue => e
      raise Exception.new("#{e.message} on "+page.to_s)
    end#end Exception
    return nok_doc
  end#end def

  def nokogiri_not_301_open(page,headers=nil)
    begin
      rest_doc = rest_client_not_301_helper(page,headers)
    rescue => e
      raise Exception.new("#{e.message} on "+page.to_s)
    end#end Exception
    return Nokogiri::HTML(rest_doc)
  end

  def rest_client_open(page)
    begin
      rest_doc = RestClient.get(page)
    rescue => e
      raise Exception.new("#{e.message} on "+page.to_s)
    end#end Exception
    return rest_doc
  end

  def rest_client_not_301_open(page)
    begin
      rest_doc = rest_client_not_301_helper(page)
    rescue => e
      raise Exception.new("#{e.message} on "+page.to_s)
    end#end Exception
    return rest_doc
  end
  
  def rest_client_not_301_helper(page,headers=nil)
    RestClient.get(page,headers){ |response, request, result, &block|
       if ["300","301","302","303","304","307"].include? response.code.to_s
        if ["404","500","401","403","406","408","501","502","503","504","505","412","414","410","409"].include? response.follow_redirection(request, result, &block).code
          response.follow_redirection(request, result, &block)
        else
          raise Exception.new("#{page} did not return a 200 but instead a #{response.code} to #{response.headers[:location]}")
        end
      else
        response.return!(request, result, &block)
      end }
  end

  def selenium_get(driver, page)
    driver.get page
  end
end
