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
class Knowledge < ActiveRecord::Base
  belongs_to :engineer, :class_name => 'User',
    :conditions => 'users.client_id IS NULL'
  belongs_to :skill
  belongs_to :software

  has_many :subscriptions, :as => :model, :dependent => :destroy

  validates_presence_of :engineer_id
  validate do |record|
    # length consistency
    if record.skill && record.software
      record.errors.add_to_base _('You have to specify a software or a domain.')
    end
    if !record.skill && !record.software
      record.errors.add_to_base _('You cannot specify a software and a domain.')
    end
  end
  # TODO : seach name of the levels ?
  # maybe a new Model ?
  validates_numericality_of :level, :integer => true,
    :greater_than => 0, :lesser_than => 6

  def name
    ( skill_id && skill_id != 0 ? skill.name : software.name )
  end

  def subscribed=(value)
    if value == '1'
      Subscription.create(:user => self.engineer, :model => self)
    else
      Subscription.destroy_by_user_and_model(self.engineer, self)
    end
  end
  
  def subscribed
    return 0 unless self.engineer and self.engineer.id and self.id
    (Subscription.all(:conditions => { :user_id => self.engineer.id,
      :model_id => self.id, :model_type => 'Knowledge'}).empty? ? 0 : 1)
  end
  
  def subscribed?
    (self.subscribed == 1)
  end

  def find_subscriptions_by_user(user)
    Subscription.all(:conditions => { :user_id => user.id,
        :model_id => self.id,
        :model_type => 'Knowledge'})
  end

end
