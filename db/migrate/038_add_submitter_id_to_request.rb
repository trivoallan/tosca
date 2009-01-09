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
class AddSubmitterIdToRequest < ActiveRecord::Migration

  class Demande < ActiveRecord::Base; end

  class Beneficiaire < ActiveRecord::Base; end

  def self.up
    add_column :demandes, :submitter_id, :integer, :null => false, :default => 0

    Demande.all.each do |d|
      d.submitter_id = Beneficiaire.first(:conditions => { :id => d.beneficiaire_id }).user_id
      d.save!
    end

    add_index :demandes, :submitter_id
  end

  def self.down
    remove_column :demandes, :submitter_id
  end
end
