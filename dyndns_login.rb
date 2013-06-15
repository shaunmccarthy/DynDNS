#!/usr/bin/env ruby
# encoding: utf-8
 
require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'tlsmail'
require 'time'
require 'parseconfig'

config = ParseConfig.new('dyndns_login.conf').params

begin

NAME     = config['dyndns_username']
PASSWORD = config['dyndns_password']
 
agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0'
 
login_page = agent.get('https://account.dyn.com/entrance/')
 
result_login = login_page.form_with(action: '/entrance/') do |form|
  form.username = NAME
  form.password = PASSWORD
end.click_button

result = result_login.body

if ( result =~ /<span>Welcome\&nbsp;<b>slyrp<\/b><\/span>/ )
  puts "Logged In"
else
  puts "Unable to login"
  raise "Failed to Login"
end

rescue
from = config['from_address']
to = config['to_address']
p = config['gmail_password']
content = <<EOF
From: #{from}
To: #{to}
subject: Unable to log in to DynDNS
Date: #{Time.now.rfc2822}
 
Sad eh?
EOF
 
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)  
Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', from, p, :login) do |smtp| 
  smtp.send_message(content, from, to)
end

end