DynDNS Auto Login
=================

DynDNS have added a new stipulation to their free dynamic domain name accounts
that you must log in to the site at least once a month; otherwise, you will 
lose your account.

Not being a fan of doing things manually, I took the lazy pragmatic approach 
and wrote a script to do it for me. It's designed to be run under a Heroku 
instance. 

It also will email you when the script breaks for any reason. This application
is for educational purposes only - I can't guarantee that it will actually count
as an official login for DynDNS's purposes, but so far it seems to work for me

Steps for local installation:
-----------------------------

1) Install the Heroku Bootstrap / Ruby if you haven't done so already. Make sure
   to install the gem bundler if you haven't already
   
   > gem install bundler

2) Download the script

   > git clone https://github.com/shaunmccarthy/DynDNS.git
   
3) Configure it to run locally

   Note: on some systems, you need to use `export`, not `set`.
   
   > set dyndns_username=yourdyndnsusername  
   > set dyndns_password=yourdyndnspassword

   If you want to be emailed whenever there is an error:
   
   > set error_email_from=a.dummy.account@gmail.com  
   > set error_email_from_password=notyourmainaccountunlessyoulikebeinghacked  
   > set error_email_to=your.normal.email@whereever.com

4) Install the package locally (make sure you have installed the bundler first)

   > bundle install

   You might need to comment out the gem "psych" line in Gemfile to get it to 
   run locally. You will need to put it back in before deploying to Heroku as they
   use syck by default to parse yaml.

4) Test it locally with 

   > ruby dyndns_login.rb

Remote Installation: Heroku
---------------------------

1) Create a Heroku account

2) Follow the quick start to get your account up and running here

   > https://devcenter.heroku.com/articles/quickstart
   
   Note where the public key is generated, as you may need this if you get the 
   dreaded "Permission denied (publickey)." error. 
   
   See http://stackoverflow.com/questions/4269922/permission-denied-publickey-when-deploying-heroku-code-fatal-the-remote-end 
   for more details. ssh-keygen can be found in C:\program files\git\bin

3) Push the code to Heroku

   > git push heroku master

   This is where you might come across the SSH error above - follow the 
   instructions in the stack overflow article

4) Set the environment variables

   > heroku config:set dyndns_username=yourdyndnsusername  
   > heroku config:set dyndns_password=yourdyndnspassword
   
   If you want to be emailed whenever there is an error:
   
   > heroku config:set error_email_from=a.dummy.account@gmail.com  
   > heroku config:set error_email_from_password=notyourmainaccountunlessyoulikebeinghacked  
   > heroku config:set error_email_to=your.normal.email@whereever.com  

5) Test the code on Heroku

   > heroku run ruby dyndns_login.rb
  
Heroku: Scheduling
------------------

1) Add the scheduler plugin

   > heroku addons:add scheduler:standard 
   
   You might need to validate your account since you potentially could go over 
   your free limit depending on how often you run this (very very unlikely 
   though). Use at own risk :)

2) Open the scheduler screen
   
   > heroku addons:open scheduler
   
3) Schedule the task to happen daily

   > $ ruby dyndns_login.rb
   
Sit back and wait for it to run :)

Feedback:
---------

Any questions, email me at git@shaunmccarthy.com
   

