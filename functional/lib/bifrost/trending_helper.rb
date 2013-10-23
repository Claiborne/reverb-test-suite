
shared_examples 'Trending Tiles Basic Checks' do

  describe 'Basic Checks' do

    it "should return a non-nil, non blank 'contentId' value for each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['contentId']
        check_not_blank tile['contentId']
      end
    end

    it "should return a non-nil, non blank 'score' value for each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['score']
        check_not_blank tile['score']
      end
    end

    it "should return a non-nil, non blank 'tileType' value for each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['tileType']
        check_not_blank tile['tileType']
      end
    end

        it "should return a 'tileType' value of 'article' or 'interest' each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['tileType']
        check_not_blank tile['tileType']
      end
    end

    it "should return a non-nil, non-blank 'header.value' value for each tile" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'article'
          check_not_nil tile['header']['value']
          check_not_blank tile['header']['value']
        end
      end
    end

    it "should return a non-nil, non blank 'header.color.red' value for each tile if article" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'article'
          check_not_nil tile['header']['color']['red']
          check_not_blank tile['header']['color']['red']
        end
      end
    end

    it "should return a non-nil, non blank 'header.color.green' value for each tile" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'article'
          check_not_nil tile['header']['color']['green']
          check_not_blank tile['header']['color']['green']
        end
      end
    end

    it "should return a non-nil, non blank 'header.color.blue' value for each tile" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'article'
          check_not_nil tile['header']['color']['blue']
          check_not_blank tile['header']['color']['blue']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.url' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage']
          check_not_nil tile['contentImage']['url']
          check_not_blank tile['contentImage']['url']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.mimeType' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage'] && tile['tileType'] == 'article'
          check_not_nil tile['contentImage']['mimeType']
          check_not_blank tile['contentImage']['mimeType']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.width' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage']
          check_not_nil tile['contentImage']['width']
          check_not_blank tile['contentImage']['width']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.height' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage']
          check_not_nil tile['contentImage']['height']
          check_not_blank tile['contentImage']['height']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.format' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage']  
          check_not_nil tile['contentImage']['format']
          check_not_blank tile['contentImage']['format']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.needsAuthentication' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage'] 
          check_not_nil tile['contentImage']['needsAuthentication']
          check_not_blank tile['contentImage']['needsAuthentication']
        end
      end
    end

    it "should return a non-nil, non blank 'contentImage.isTransparent' value for each tile if contentImage" do
      @data['tiles'].each do |tile|
        if tile['contentImage']
          check_not_nil tile['contentImage']['isTransparent']
          check_not_blank tile['contentImage']['isTransparent']
        end
      end
    end

    it "should return a non-nil, non blank 'count.items' value for each tile if interest" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'interest'
          check_not_nil tile['count']['items']
          check_not_blank tile['count']['items']
        end
      end
    end

    it "should return a non-nil, non blank 'publishDate' value for each tile of article" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'article'
          check_not_nil tile['publishDate']
          check_not_blank tile['publishDate']
        end
      end
    end

    it "should return a non-nil, non blank 'accessedOn' value for each tile of interest" do
      @data['tiles'].each do |tile|
        if tile['tileType'] == 'interest'
          check_not_nil tile['accessedOn']
          check_not_blank tile['accessedOn']
        end
      end
    end

    it "should return a non-nil, non blank 'known' value for each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['known']
        check_not_blank tile['known']
      end
    end

    it "should return a non-nil, non blank 'shareUrl' value for each tile" do
      @data['tiles'].each do |tile|
        check_not_nil tile['shareUrl']
        check_not_blank tile['shareUrl']
      end
    end
  end
end
