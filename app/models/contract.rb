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
class Contract < ActiveRecord::Base
  belongs_to :client
  belongs_to :rule, :polymorphic => true
  belongs_to :creator, :class_name => 'User'
  belongs_to :salesman, :class_name => 'Ingenieur'

  has_many :issues
  has_many :appels
  has_many :tags
  has_many :releases

  has_and_belongs_to_many :versions, :order => 'versions.name DESC', :uniq => true
  has_and_belongs_to_many :commitments, :uniq => true, :order =>
    'typeissue_id, severity_id', :include => [:severity,:typeissue]
  has_and_belongs_to_many :users, :order => 'users.name', :uniq => true
  # Those 2 ones are helpers, not _real_ relation ship
  has_and_belongs_to_many :engineer_users, :class_name => 'User',
    :conditions => 'users.client = 0',
    :order => 'users.name ASC'
  has_and_belongs_to_many :recipient_users, :class_name => 'User',
    :conditions => 'users.client = 1', :include => :recipient,
    :order => 'users.name ASC'
  has_and_belongs_to_many :teams, :order => 'teams.name', :uniq => true

  validates_presence_of :client, :rule, :creator
  validates_numericality_of :opening_time, :closing_time,
    :only_integer => true
  validates_inclusion_of :opening_time, :closing_time, :in => 0..24

  validate :must_open_before_close

  def must_open_before_close
    valid = true
    if self.opening_time.to_i > self.closing_time.to_i
      self.errors.add_to_base("The schedules of this contract are invalid.")
      valid = false
    end
    valid
  end

  after_save do |record|
    # To make sure we have only one time a engineer
    record.engineer_users = record.engineer_users - (record.teams.collect { |t| t.users }.flatten)
    true
  end


  Rules = [ 'Rules::Credit', 'Rules::Component' ]

  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contracts.id IN (?)', contract_ids ] } }
  end

  def engineers
    engineers = self.engineer_users
    engineers.concat(self.teams.collect { |t| t.users }.flatten).uniq!
    engineers
  end

  def credit?
    rule_type == Rules.first
  end

  def interval_in_seconds
    return (closing_time - opening_time) * 1.hour
  end

  def interval
    closing_time - opening_time
  end

  # We have open clients which can declare
  # issues on everything. It's with the "socle" field.
  def softwares
    if rule_type == 'Rules::Component' and rule.max == -1
      return Software.find(:all, :order => 'softwares.name ASC')
    end
    Software.find(:all, :conditions => { "contracts.id" => self.id },
      :joins => { :versions => :contracts },
      :group => "versions.software_id")
  end

  # TODO : I am sure it could be better. Rework model ???
  def find_recipients_select
    options = { :conditions => 'users.inactive = 0' }
    self.recipient_users.find(:all, options).collect{|u|
      [  u.name, u.recipient.id ] if u.recipient }
  end

  def start_date_formatted
    display_time read_attribute(:start_date)
  end

  def end_date_formatted
    display_time read_attribute(:end_date)
  end

  def find_commitment(issue)
    options = { :conditions =>
      [ 'commitments.typeissue_id = ? AND severity_id = ?',
        issue.typeissue_id, issue.severity_id ] }
    self.commitments.find(:first, options)
  end

  def typeissues
    joins = 'INNER JOIN commitments ON commitments.typeissue_id = typeissues.id '
    joins << 'INNER JOIN commitments_contracts ON commitments.id = commitments_contracts.commitment_id'
    conditions = [ 'commitments_contracts.contract_id = ? ', id ]
    Typeissue.find(:all,
                     :select => "DISTINCT typeissues.*",
                     :conditions => conditions,
                     :joins => joins)
  end

  INCLUDE = [:client]
  ORDER = 'clients.name ASC'
  OPTIONS = { :include => INCLUDE, :order => ORDER, :conditions =>
    "clients.inactive = 0" }

  def name
    specialisation = read_attribute(:name)
    res = "#{client.name} - #{rule.name}"
    res << " - #{specialisation}" unless specialisation.blank?
    res
  end
  
  def total_elapsed
    total = 0
    self.issues.each do |r|
      total += r.elapsed.until_now
    end
    total
  end

end
