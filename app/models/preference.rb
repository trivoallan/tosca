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
# Represents a preferred value for a particular preference on a model.
#
# == Targeted preferences
#
# In addition to simple named preferences, preferences can also be targeted for
# a particular record.  For example, a User may have a preferred color for a
# particular Car.  In this case, the +owner+ is the User, the +preference+ is
# the color, and the +target+ is the Car.  This allows preferences to have a sort
# of context around them.

# If needed, it can be specialised into a User::Preference
class Preference < ActiveRecord::Base
  belongs_to  :owner,
                :polymorphic => true
  belongs_to  :preferenced,
                :polymorphic => true

  validates_presence_of :attribute,
                        :owner_id,
                        :owner_type
  validates_presence_of :preferenced_id,
                        :preferenced_type,
                          :if => Proc.new {|p| p.preferenced_id? || p.preferenced_type?}

  # The definition for the attribute
  def definition
    owner_type.constantize.preference_definitions[attribute] if owner_type
  end

  # Typecasts the value depending on the preference definition's declared type
  def value
    value = read_attribute(:value)
    value = definition.type_cast(value) if definition
    value
  end
end
