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
class Release < ActiveRecord::Base
  include Comparable

  belongs_to :version
  belongs_to :contract

  has_one :changelog, :dependent => :destroy

  has_many :archives, :dependent => :destroy

  validates_presence_of :version

  def full_name
    @full_name ||= "#{self.version.full_name} r#{self.name}"
  end

  def full_software_name
    @full_software_name ||= "#{self.version.full_software_name} r#{self.name}"
  end

  def software
    version.software
  end

  def <=>(other)
    return 1 if other.nil? or not other.is_a?(Release)
    res = self.version <=> other.version
    return res unless res == 0
    self.name <=> other.name
  end

  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'releases.contract_id IN (?)', contract_ids ]
      } } if contract_ids
  end

  #This model is scoped by Contract
  def self.scoped_contract?
    true
  end

end
