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
class Team < ActiveRecord::Base

  belongs_to :contact, :class_name => 'User',
    :foreign_key => 'contact_id'

  has_one :alert, :dependent => :destroy

  has_many :users
  named_scope :on_contract_id, lambda { |contract_id |
    { :conditions => ['ct.contract_id = ?', contract_id],
      :joins => 'INNER JOIN contracts_teams ct ON ct.team_id=teams.id'}
  }

  has_and_belongs_to_many :contracts, :uniq => true

  validates_uniqueness_of :name
  validates_presence_of :name, :contact

  # Nice URL
  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def self.find_select_by_contract_id(contract_id)
    joins = 'INNER JOIN contracts_users cu ON cu.user_id=users.id'
    conditions = [ 'cu.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => joins}}
    User.send(:with_scope, options) do
      User.find_select(User::SELECT_OPTIONS)
    end
  end

  def engineers_id
    self.engineers_collection_select.collect { |e| e.id }
  end

  def engineers_collection_select
    options = { :conditions => ['users.inactive = ? AND users.client_id IS NULL', false ],
      :order => 'users.name', :select => 'users.id, users.name' }
    self.users.all(options)
  end

  def issues
    conditions = [ 'issues.contract_id IN (?) AND issues.statut_id = 1', self.contract_ids ]
    Issue.all(:conditions => conditions)
  end

end
