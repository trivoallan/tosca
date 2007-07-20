require 'rubygems' rescue nil
require 'irb/completion'
require 'what_methods'
require 'pp'
require 'wirble'

IRB.conf[:AUTO_INDENT]=true
Wirble.init
Wirble.colorize
