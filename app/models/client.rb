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
class Client < ActiveRecord::Base
  # Small utils for inactive, located in /lib/inactive_record.rb
  include InactiveRecord

  belongs_to :image
  has_many :recipients, :dependent => :destroy
  has_many :active_recipients, :class_name => 'Recipient', :include => :user,
    :conditions => 'users.inactive = 0'
  has_many :contracts, :dependent => :destroy
  has_many :documents, :dependent => :destroy

  has_and_belongs_to_many :socles, :uniq => true

  has_many :versions, :through => :contracts
  has_many :issues, :through => :recipients # , :source => :issues

  belongs_to :creator, :class_name => 'User'

  validates_presence_of :name, :creator
  validates_length_of :name, :in => 3..50

  SELECT_OPTIONS = { :include => {:recipients => [:user]},
    :conditions => 'clients.inactive = 0 AND users.inactive = 0' }

  after_save :desactivate_recipients

  def desactivate_recipients
    begin
      connection.begin_db_transaction
      value = (inactive? ? 1 : 0)
      connection.update "UPDATE users u, recipients b SET u.inactive = #{value} WHERE b.client_id=#{self.id} AND b.user_id=u.id"
      connection.commit_db_transaction
    rescue Exception => e
      connection.rollback_db_transaction
      errors.add_to_base(_('Cannot (de)activate associated recipients due to : "%s"') % e.message)
      return false
    end
    true
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|address|image|inactive)$/
    }
  end

  # don't use this function outside of an around_filter
  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'clients.id IN (?)', client_ids ]} }
  end

  def contract_ids
    self.contracts.find(:all, :select => 'id').collect{|c| c.id}
  end

  # TODO : it's slow & ugly
  # returns true if we have a contract to support an entire distribution
  # for this client, false otherwise.
  def support_distribution
    result = false
    self.contracts.each { |c| result = true if c.rule.max == -1 }
    result
  end

  def recipient_ids
    @recipient_ids ||= self.recipients.find(:all, :select => 'id').collect{|c| c.id}
  end

  def ingenieurs
    return [] if contracts.empty?
    options = { :include => [:user],
      :conditions => [ 'cu.contract_id IN (?)', contract_ids ],
      :joins => 'INNER JOIN contracts_users cu ON cu.user_id=users.id' }
    Ingenieur.find(:all, options)
  end

  def softwares
    return [] if contracts.empty?
    return contracts.first.softwares if contracts.size == 1
    # speedier if there is one openbar contract
    contracts.each { |c| return Software.find(:all) if c.rule.max == -1 }

    # default case, when there is an association with releases.
    conditions = [ 'softwares.id IN (SELECT DISTINCT versions.software_id ' +
                   ' FROM versions WHERE versions.contract_id IN (?)) ',
                   contracts.collect{ |c| c.id } ]
    Software.find(:all, :conditions => conditions, :order => 'softwares.name')
  end

  def contributions
    return [] if issues.empty?
    Contribution.find(:all,
                   :conditions => "contributions.id IN (" +
                     "SELECT DISTINCT issues.contribution_id FROM issues " +
                     "WHERE issues.recipient_id IN (" +
                     recipients.collect{|c| c.id}.join(',') + "))"
                   )
  end

  def typeissues
    joins = 'INNER JOIN commitments ON commitments.typeissue_id = typeissues.id '
    joins << 'INNER JOIN commitments_contracts ON commitments.id = commitments_contracts.commitment_id'
    conditions = [ 'commitments_contracts.contract_id IN (' +
        'SELECT contracts.id FROM contracts WHERE contracts.client_id = ?)', id ]
    Typeissue.find(:all,
                     :select => "DISTINCT typeissues.*",
                     :conditions => conditions,
                     :joins => joins)
  end

  # TODO : à revoir, on pourrait envisager de moduler les sévérités selon
  # les type de issues
  def severites
    Severite.find(:all)
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
  def self.find_select(options = { }, collect = true)
    find_active4select(options, collect)
  end

end
