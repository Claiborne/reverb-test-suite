module APIChecker
  
  #Check API response is 200
  def check_200(response)
    response.code.should eql(200)
  end
  
  #Check API data does not return a blank value
  def check_not_blank(data)
    data.to_s.length.should > 0
    data.to_s.delete("^a-zA-Z0-9").length.should > 0
  end
  
  #Check API data does not return a nil value
  def check_not_nil(data)
    data.should_not be_nil  
  end
  
  #Check API json returns specificied number of indicies
  def check_indices(data, num)
    data.length.should == num
  end
end