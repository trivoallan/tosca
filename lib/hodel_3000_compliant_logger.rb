#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
    "#{timestamp.strftime('%b %d %H:%M:%S')} #{@@hostname} rails[#{$PID}]: #{progname.gsub(/\n/, '').lstrip}\n"
  end
end
