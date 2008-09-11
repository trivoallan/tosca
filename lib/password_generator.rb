#
# Copyright (c) 2006-2008 Linagora
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
module PasswordGenerator

  @@mkpasswd = nil
  def generate_password
    @@mkpasswd ||= File.exist?('/usr/bin/mkpasswd')
    generated = ''
    # mkpasswd bug with control characters
    # so, we hash the string to resolve this problem
    seed = "--#{rand(10000)}--#{Time.now}--#{self.login}--".hash.to_s
    if @@mkpasswd
      generated = %x[#{"echo '#{seed}' | /usr/bin/mkpasswd"}]
      generated.chomp!
    else
      generated = Digest::SHA1.hexdigest(seed)[0,10]
    end
    self.pwd, self.pwd_confirmation = Array.new(2, generated)
  end

end
