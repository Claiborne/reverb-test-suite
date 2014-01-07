module FeChecker
  
  #To include this module:
  #require 'fe_checker'
  #include FeChecker
  
  require 'open_page.rb'
  include OpenPage
  
  def check_display_text(locator)
    @doc.at_css("#{locator}").should be_true
    @doc.css(locator).text.delete("^a-zA-Z").length.should > 0
  end
  
  def check_display_text_for_each(locator)
    @doc.at_css("#{locator}").should be_true
    @doc.css(locator).each do |li|
      li.text.delete("^a-zA-Z").length.should > 0
    end
  end
  
  def check_have_a_link(locator)
    @doc.css("#{locator} a").count.should > 0
    @doc.css("#{locator} a[href*='http']").count.should > 0
  end
  
  def check_have_a_link_for_each(locator)
    @doc.at_css("#{locator} a").should be_true
    @doc.css(locator).each do |li|
      li.at_css("a[href*='http']").should be_true
    end
  end
  
  def check_have_an_img(locator)
    @doc.css("#{locator} img").count.should > 0
    @doc.css("#{locator} img[src*='http']").count.should > 0
  end
  
  def check_have_an_img_for_each(locator)
    @doc.at_css("#{locator} img").should be_true
    @doc.css(locator).each do |li|
      li.at_css("img").should be_true
      li.at_css("img[src*='http']").should be_true
    end
  end
  
  def check_include_at_least_one_css_file(doc)
    doc.css("head link[@href*='.css']").count.should > 0
  end
  
  def check_css_files(doc)
    doc.css("link[@href*='.css']").each do |css|
      response = rest_client_open css.attribute('href').to_s
      response.code.should_not eql(/4\d\d/)
      response.code.should_not eql(/5\d\d/)
      response.code.should eql(200)
    end
  end
  
  ############# START LINK CHECKERS #############
  
  def check_for_broken_links(locator)
    #@doc.css("#{locator} a[href*='http']").each do |a|
    @doc.css("#{locator} a").each do |a|
      if a.attribute('js-href')
        link = a.attribute('js-href').to_s
        response = rest_client_open link
        response.code.should eql(200)
      else
        link = a.attribute('href').to_s
        response = rest_client_open link
        response.code.should eql(200)
      end
    end
  end
  
  def check_for_broken_images(locator)
    #@doc.css("#{locator} img[src*='http']").each do |img|
    @doc.css("#{locator} img").each do |img|
      img_src = img.attribute('src').to_s
      response = rest_client_open img_src
      response.code.should eql(200)
    end
  end

  def check_for_broken_images_se(locator)
    #@doc.css("#{locator} img[src*='http']").each do |img|
    @selenium.find_elements(:css => "#{locator} img").count.should > 0
    @selenium.find_elements(:css => "#{locator} img").each do |img|
      img_src = img.attribute('src').to_s
      response = rest_client_open img_src
      response.code.should eql(200)
    end
  end
  
  def check_links_not_301_home(locator)
    #@doc.css("#{locator} a[href*='http']").each do |a|
    @doc.css("#{locator} a").each do |a|
      if a.attribute('js-href')
        link = a.attribute('js-href').to_s
        response = rest_client_not_301_home_open link
        response.code.should eql(200)
      else
        link = a.attribute('href').to_s
        response = rest_client_not_301_home_open link
        response.code.should eql(200)
      end
    end
  end
  
  def check_links_not_301(locator)
    #@doc.css("#{locator} a[href*='http']").each do |a|
    @doc.css("#{locator} a").each do |a|
      if a.attribute('js-href')
        link = a.attribute('js-href').to_s
        response = rest_client_not_301_open link
        response.code.should eql(200)
      else
        link = a.attribute('href').to_s
        response = rest_client_not_301_open link
        response.code.should eql(200)
      end
    end
  end
  ############# END LINK CHECKERS #############
end