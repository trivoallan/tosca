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
class Team < ActiveRecord::Base

  belongs_to :contact, :class_name => 'User',
    :foreign_key => 'contact_id'

  has_one :alert
  
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
    Ingenieur.send(:with_scope, options) do
      Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  def engineers_id
    options = { :conditions => 'users.client = 0 AND users.inactive = 0',
      :joins => 'INNER JOIN ingenieurs ON ingenieurs.user_id=users.id',
      :order => 'users.name', :select => 'ingenieurs.id' }
    self.users.find(:all, options).collect{|e| e.id}
  end

  def engineers_collection_select
    options = { :conditions => 'users.client = 0 AND users.inactive = 0',
      :joins => 'INNER JOIN ingenieurs ON ingenieurs.user_id=users.id',
      :order => 'users.name', :select => 'ingenieurs.id, users.name' }
    self.users.find(:all, options)
  end

end
