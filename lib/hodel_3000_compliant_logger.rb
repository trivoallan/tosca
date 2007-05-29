require 'logger'
require 'English'
# Jan  2 03:38:05 topfunky postfix/postqueue[2947]: warning blah blah blah

##
# A logger for use with pl_analyze and other tools that expect syslog-style log output.

class Hodel3000CompliantLogger < Logger
  
  ##
  # Note: If you are using FastCGI you may need to hard-code the hostname here instead of using Socket.gethostname
  @@hostname = Socket.gethostname.split('.').first

  def format_message(severity, timestamp, msg, progname) 
    "#{timestamp.strftime("%b %d %H:%M:%S")} #{@@hostname} rails[#{$PID}]: #{progname.gsub(/\n/, '').lstrip}\n"
  end
end
