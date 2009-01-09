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
Start = 31
Deviation = 1

Dir.foreach('migrate/') do |m|
  if m =~ /^\d+_.*\.rb$/
    file = m.split(/_/, 2)
    idx = file.first.to_i
    if idx > Start
      puts "mv #{m} #{idx + Deviation}_#{file.last}"
      File.rename("migrate/#{m}", "0#{idx + Deviation}_#{file.last}")
    end
  end
end
