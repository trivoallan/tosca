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
class Commitment < ActiveRecord::Base
  belongs_to :severite
  belongs_to :typeissue
  has_and_belongs_to_many :contracts, :uniq => true

  validates_each :correction, :workaround do |record, attr, value|
    record.errors.add attr, 'must be >= 0.' if value < 0 and value != -1
  end

  # Our agreement for 0 SLA is '-1' in the database.
  # But the user does not need to learn this.
  def correction=(value)
    value = value.to_f
    write_attribute(:correction, (value == 0.0 ? -1 : value))
  end
  def workaround=(value)
    value = value.to_f
    write_attribute(:workaround, (value == 0.0 ? -1 : value))
  end

  def to_s
    "#{self.typeissue.name} | #{self.severite.name} : " +
      "#{Time.in_words(self.workaround.days, true)} " +
      "/ #{Time.in_words(self.correction.days, true)}"
  end

  INCLUDE = [:typeissue,:severite]
  ORDER = 'commitments.typeissue_id, commitments.severite_id DESC, commitments.workaround DESC'
  OPTIONS = { :include => INCLUDE, :order => ORDER }

end
