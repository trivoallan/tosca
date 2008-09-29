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
class Recipient < ActiveRecord::Base
  belongs_to :user
  belongs_to :client, :counter_cache => true
  has_many :phonecalls

  INCLUDE = [:user]

  # TODO : revoir la hiérarchie avec un nested tree (!)
  belongs_to :recipient
  has_many :issues, :dependent => :destroy

  validates_presence_of :client

  def name
    (user ? user.name : '-')
  end

  def contract_ids
    @cache ||= user.contract_ids
  end

  def contracts
    self.user.contracts
  end

end
