require 'rest-client'

r = RestClient.get "https://s3.amazonaws.com/uploads.hipchat.com/20394/488506/zIHLEVf6e3cDj6i/load_test.json#"

ary =[]
f = File.open('/Users/wclaiborne/Desktop/odin_docs_dev.txt', 'w') 

r.scan(/\w+/) do |w|
  if w.match(/\d/)
    f.write w
    f.write "\n"
  end
end

