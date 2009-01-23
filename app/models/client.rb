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
class Client < ActiveRecord::Base
  # Small utils for inactive, located in /lib/inactive_record.rb
  include InactiveRecord

  belongs_to :picture, :dependent => :destroy

  has_many :recipients, :class_name => 'User', :dependent => :destroy,
    :conditions => 'users.client_id IS NOT NULL'
  has_many :active_recipients, :class_name => 'User',
    :conditions => [ 'users.inactive = ? AND users.client_id IS NOT NULL', false ]
  has_many :contracts, :dependent => :destroy

  has_many :versions, :through => :contracts
  has_many :issues, :through => :recipients

  belongs_to :creator, :class_name => 'User'

  validates_presence_of :name, :creator
  validates_length_of :name, :in => 3..50

  SELECT_OPTIONS = { :include => :recipients,
    :conditions => ['clients.inactive = ? AND users.inactive = ?', false, false ] }

  after_save :desactivate_recipients

  def desactivate_recipients
    self.recipients.each do |r|
      r.update_attribute(:inactive, self.inactive)
    end
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|address|picture|inactive)$/
    }
  end

  # don't use this function outside of an around_filter
  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'clients.id IN (?)', client_ids ]} }
  end

  # TODO : it's slow & ugly
  # returns true if we have a contract to support an entire distribution
  # for this client, false otherwise.
  def support_distribution
    result = false
    self.contracts.each do |c|
      if c.rule.max == -1
        result = true 
        break
      end
    end
    result
  end

  def recipient_ids
    @recipient_ids ||= self.recipients.all(:select => 'id').collect(&:id)
  end

  def engineers
    return [] if contracts.empty?
    options = { :conditions => [ 'cu.contract_id IN (?) AND users.client_id IS NULL', contract_ids ],
      :joins => 'INNER JOIN contracts_users cu ON cu.user_id=users.id' }
    User.all(options)
  end

  def softwares
    return [] if contracts.empty?
    return contracts.first.softwares if contracts.size == 1
    # speedier if there is one openbar contract
    contracts.each { |c| return Software.all if c.rule.max == -1 }

    # default case, when there is an association with releases.
    conditions = [ 'softwares.id IN (SELECT DISTINCT versions.software_id ' +
                   ' FROM versions WHERE versions.contract_id IN (?)) ',
                   contracts_ids ]
    Software.all(:conditions => conditions, :order => 'softwares.name')
  end

  def contributions
    return [] if self.recipients.empty?
    Contribution.all(:conditions => "contributions.id IN (" +
                        "SELECT DISTINCT issues.contribution_id FROM issues " +
                        "WHERE issues.recipient_id IN (" +
                        recipients.collect{|c| c.id}.join(',') + "))")
  end

  def issuetypes
    joins = 'INNER JOIN commitments ON commitments.issuetype_id = issuetypes.id '
    joins << 'INNER JOIN commitments_contracts ON commitments.id = commitments_contracts.commitment_id'
    conditions = [ 'commitments_contracts.contract_id IN (' +
        'SELECT contracts.id FROM contracts WHERE contracts.client_id = ?)', id ]
    Issuetype.all(:select => "DISTINCT issuetypes.*",
                  :conditions => conditions,
                  :joins => joins)
  end

  # TODO : it could & should be dynamic. Is there really a sense to severity
  # for an evolution issue ?
  def severities
    Severity.all
  end

  # pretty urls for client
  def to_param
    "#{id}-#{read_attribute(:name).gsub(/[^a-z1-9]+/i, '-')}"
  end

  # can return an htmled name if deactivated
  def name
    strike(:name)
  end

  # will always be clean
  def name_clean
    read_attribute(:name)
  end

  # specialisation, since a Client can be "inactive".
  def self.find_select(options = {}, collect = true)
    find_active4select(options, collect)
  end

  #This model is scoped by Client
  def self.scope_client?
    true
  end

end
