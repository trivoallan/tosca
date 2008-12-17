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
# This class represent a phone Call for an Issue from a Recipient to
# an Engineer. There's also a link to the contract, because those phones
# calls can be in the 24/24 contract.
class Phonecall < ActiveRecord::Base
  belongs_to :engineer, :class_name => 'User',
    :conditions => 'users.client_id IS NULL'
  belongs_to :recipient, :class_name => 'User',
    :conditions => 'users.client_id IS NOT NULL'
  belongs_to :issue
  belongs_to :contract

  N_('phonecall')

  validate do |record|
    # length consistency
    if record.end < record.start
      record.errors.add_to_base _('The beginning of the call has to be before to its end.')
    end
    # recipient consistency
    if record.recipient and
      record.recipient.client_id != record.contract.client_id
      record.errors.add_to_base _('recipient and client have to correspond.')
    end
  end
  validates_presence_of :engineer, :contract

  # This reduced the scope of Calls to contract_ids in parameters.
  # With this, every Recipient only see what he is concerned of
  def self.set_scope(contract_ids)
    if contract_ids
      self.scoped_methods << { :find => { :conditions =>
          [ 'phonecalls.contract_id IN (?)', contract_ids ] } }
    end
  end

  # end of the phone call, formatted without the need to load Time.
  # See ActiveRecord::Base for more information
  def end_formatted
    display_time read_attribute(:end)
  end

  # start of the phone call, formatted without the need to load Time.
  # See ActiveRecord::Base for more information
  def start_formatted
    display_time read_attribute(:start)
  end

  def length
    # end is a reserved word for ruby ...
    self.end - self.start
  end

  def name
    if issue
      _("Phonecall of %s on '%s'") % [ Time.in_words(length), issue.resume ]
    else
      _("Phonecall of %s for %s") % [ engineer.name, contract.name ]
    end
  end

end
