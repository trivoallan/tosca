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
class Ingenieur < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy

  has_many :knowledges, :order => 'knowledges.level DESC'
  has_many :issues
  has_many :phonecalls
  
  INCLUDE = [:user]

  def self.find_select_by_contract_id(contract_id)
    joins = 'INNER JOIN contracts_users cu ON cu.user_id=users.id'
    conditions = [ 'cu.contract_id = ?', contract_id ]
    options = {:find => {:conditions => conditions, :joins => joins}}
    Ingenieur.send(:with_scope, options) do
      Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  # Don't forget to make an :include => [:user] if you
  # use this small wrapper.
  def name
    user.name
  end

  def trigram
    @trigram ||= user.login[0..2].upcase!
  end

end
