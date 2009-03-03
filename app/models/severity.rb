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
class Severity < ActiveRecord::Base
  has_many :issues
  has_many :commitments


  # It's one of the rare "heavily used & fixed" AR model,
  # So we can include it in the translation mechanism
  def name
    _(read_attribute(:name))
  end

  private
  def fake4translation
    ####################
    N_('Blocking') # 1 #
    N_('Major')    # 2 #
    N_('Minor')    # 3 #
    N_('None')     # 4 #
    ####################
  end
end
