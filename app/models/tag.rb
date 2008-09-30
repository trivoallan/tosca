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

require_dependency 'vendor/plugins/acts_as_taggable_on_steroids/lib/tag.rb'
class Tag

  belongs_to :user
  belongs_to :competence
  belongs_to :contract

  def full_name
    name = self.name.dup
    if self.contract_id
      name << " (#{self.contract.name})"
    elsif self.competence_id
      name << " (#{self.competence.name})"
    else
      #Something ?
    end
    name
  end

  # See ApplicationController#scope
  # Users can only see their contractual tags or generic ones
  def self.set_scope(contract_ids)
    scope = { :conditions =>
      [ 'tags.contract_id IN (?) OR tags.contract_id IS NULL', contract_ids ] }
    self.scoped_methods << { :find => scope, :count => scope }
  end

  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def self.find_or_create_with_like_by_name_and_contract_id(name, contract_id)
    conditions = ["tags.name LIKE ? AND tags.contract_id = ?", name, contract_id]
    self.first(:conditions => conditions) || self.create(:name => name, :contract_id => contract_id)
  end

  def self.get_generic_tag
    return Tag.find(:all, :conditions => ["competence_id IS NULL and contract_id IS NULL"] )
  end

  def self.get_competence_tag(competences = nil)
    if competences.nil?
      conditions = ["competence_id IS NOT NULL"]
    else
      conditions = ["competence_id IN (?) ", competences ]
    end
    return Tag.find( :all, :conditions => conditions )
  end

  def self.get_contract_tag(contracts = nil)
    if contracts.nil?
      conditions = ["contract_id IS NOT NULL"]
    else
      conditions = ["contract_id IN (?) ", contracts ]
    end
    return Tag.find( :all, :conditions => conditions )
  end

end
