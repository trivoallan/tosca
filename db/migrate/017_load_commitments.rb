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
class LoadCommitments < ActiveRecord::Migration
  class Engagement < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Commitments
    return unless Engagement.count == 0

    # Sample commitments
    blocking, major, minor, none = 1, 2, 3, 4
    information, issue = 1, 2

    add_commitment = Proc.new do |severity_id, typerequest_id, workaround, fix|
      attr = { :severite_id => severity_id, :typedemande_id => typerequest_id,
        :correction => fix, :contournement => workaround }
      Engagement.create(attr)
    end

    add_commitment.call(blocking, issue, 0.16, 5)
    add_commitment.call(major, issue, 5, 20)
    add_commitment.call(minor, issue, 5, -1)

    add_commitment.call(blocking, information, -1, 1)
    add_commitment.call(major, information, -1, 1)
    add_commitment.call(minor, information, -1, 1)
  end

  def self.down
    Engagement.all.each{ |e| e.destroy }
  end
end
