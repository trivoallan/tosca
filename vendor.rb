#!/usr/bin/env ruby

# You want to call it like this :
# find . -name "*.rb" | grep -v "vendor" | xargs ./vendor.rb

require 'fileutils'

copyright = <<-EOF
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

EOF

copyright = copyright.split "\n"
# need to add it back for comparison with readlines
copyright.each { |l| l << "\n" }

tmp = "/tmp/tmp.rb"
$*.each do |arg|
  File.open(arg, File::RDWR) do |file|
    lines = file.readlines
    unless (copyright - lines).empty?
      file.rewind
      file.print copyright
      file.print lines
    end
  end
end
