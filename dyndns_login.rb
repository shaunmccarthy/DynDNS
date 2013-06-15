#!/usr/bin/env ruby
# encoding: utf-8

# Required to automagically request the other gems at runtime 
require 'rubygems'
require 'bundler/setup'

# For browser automation
require 'mechanize'

# To send out logging emails
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

  # connect to the dyndns site with a pretend browser and go to the login page
  # based off of https://gist.github.com/meise/5585311
  agent = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0'
 
  login_page = agent.get('https://account.dyn.com/entrance/')

  # login 
  result_login = login_page.form_with(action: '/entrance/') do |form|
    form.username = dyndns_username
    form.password = dyndns_password
  end.click_button

  # Check we succeeded
  result = result_login.body

  if ( result =~ /<span>Welcome\&nbsp;<b>#{dyndns_username}<\/b><\/span>/ )
    puts "Logged In"
  else
    # Throw an error
    puts "Unable to login"
    raise "Failed to Login"
  end

# If we get an error, try and send an email to error_email_to telling them that something
# went wrong
rescue Exception => e 

  # If we don't have a email then just dump to console
  if error_email_from.nil?
    puts "Not sending error email since error_email_from is not set:\n#{e.message}\n#{e.backtrace.inspect}"
  else
    # Create the email
    content = <<EOF
From: #{error_email_from}
To: #{error_email_to}
subject: Unable to log in to DynDNS
Date: #{Time.now.rfc2822}
 
Error is...
#{e.message}
#{e.backtrace.inspect}
EOF

    # Debug to console
    print content

    # Send the email 
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)  
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', error_email_from, error_email_from_password, :login) do |smtp| 
      smtp.send_message(content, error_email_from, error_email_to)
    end
  end
end