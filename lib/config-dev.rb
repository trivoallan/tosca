# Include your application configuration below
ActionMailer::Base.server_settings = {
  :address  => "mail.linagora.com",
  :port  => 25, 
  :domain  => 'linagora.com'

  #:user_name  => "",
  #:password  => "",
#  :authentication  => :login
} 
ActionMailer::Base.default_charset = "ISO-8859-1"

