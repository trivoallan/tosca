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
class LoadCopyrights < ActiveRecord::Migration
  class License < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Licenses
    return unless License.count == 0

    # Sample OS License
    [ [ 'BSD', 'http://www.edgewall.com/trac/license.html' ],
      [ 'GPL', 'http://www.gnu.org/copyleft/gpl.html' ],
      [ 'LGPL', 'http://www.gnu.org/copyleft/lgpl.html' ],
      [ 'MPL', 'http://www.mozilla.org/MPL/' ]
    ].each { |l| License.create(:nom => l.first, :url => l.last,
                                :certifie_osi => true) }
  end

  def self.down
    License.all.each{ |l| l.destroy }
  end
end
