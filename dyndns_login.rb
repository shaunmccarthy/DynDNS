#!/usr/bin/env ruby
# encoding: utf-8
 
require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'tlsmail'
require 'time'

# The username and password we are going to try to authenticate against dyndns with
# Set via heroku config:set dyndns_username=xxx
dyndns_username = ENV['dyndns_username']
dyndns_password = ENV['dyndns_password']

# If you want an error email when things go wrong, set these values (from address must be a gmail account)
error_email_from = ENV['error_email_from']
error_email_from_password = ENV['error_email_from_password']
error_email_to = ENV['error_email_to']

begin

  agent = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0'
 
  login_page = agent.get('https://account.dyn.com/entrance/')
 
  result_login = login_page.form_with(action: '/entrance/') do |form|
    form.username = dyndns_username
    form.password = dyndns_password
  end.click_button

  result = result_login.body

  if ( result =~ /<span>Welcome\&nbsp;<b>slyrp<\/b><\/span>/ )
    puts "Logged In"
  else
    puts "Unable to login"
    raise "Failed to Login"
  end

rescue Exception => e 
  if error_email_from.nil?
    puts "Not sending error email since error_email_from is not set"
  else
    content = <<EOF
From: #{error_email_from}
To: #{error_email_to}
subject: Unable to log in to DynDNS
Date: #{Time.now.rfc2822}
 
Error is...
#{e.message}
#{e.backtrace.inspect}
EOF

    print content
 
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)  
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', error_email_from, error_email_from_password, :login) do |smtp| 
      smtp.send_message(content, error_email_from, error_email_to)
    end
  end
end