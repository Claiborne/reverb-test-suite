require 'net/smtp'

file = File.open("/home/wclaiborne/bifrost-prd-results.txt")
contents = ""
file.each {|line|
  contents << line
}

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = "qa@helloreverb.com"

msgstr = <<END_OF_MESSAGE
From: Reverb QA <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Bifrost Results in Production
#{contents}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end
