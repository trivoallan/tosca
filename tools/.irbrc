# See http://cbenz.tuxfamily.org/index.php?n=Main.Irb for more info
require 'rubygems' rescue nil
require 'irb/completion'
# See http://www.nobugs.org/developer/ruby/method_finder.html
require 'what_methods'
require 'pp'
require 'wirble'

IRB.conf[:AUTO_INDENT]=true
Wirble.init
Wirble.colorize
