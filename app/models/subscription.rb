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
class Subscription < ActiveRecord::Base
  belongs_to :user
  # Subscription can be made on
  # * Contract : emails for all issues
  # * Issue : emails for a specific issue
  # * Software : emails for all issues about a specific software
  belongs_to :model, :polymorphic => true

  validates_presence_of :user, :model
  validates_uniqueness_of :user_id, :scope => [ :model_type, :model_id ],
    :message => 'You can be suscribe only one time on this model.'

  def name
    _('Subscription for %s on %s #%s') %
      [ self.user.name, self.model_type, self.model_id ]
  end

  def self.destroy_by_user_and_model(user, model)
    self.first(:conditions => { :user_id => user.id, :model_type =>
                 model.class.to_s, :model_id => model.id }).destroy
  end

  before_destroy :check_uniqueness
  # For Contract, it MUST have at least one user watching it.
  def check_uniqueness
    return true if self.model_type != 'Contract'
    similars = { :model_type => self.model_type, :model_id => self.model_id }
    if self.class.count(:conditions => similars) <= 1
      self.errors.add_to_base(_('You can not unsubscribe to this contract, because your are the only one watching it.'))
      false
    else
      true
    end
  end

end
