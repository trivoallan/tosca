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
class EnglishBeneficiaire2recipient < ActiveRecord::Migration
  def self.up
    # These columns were not used
    remove_column :beneficiaires, :notifier_subalternes
    remove_column :beneficiaires, :notifier
    remove_column :beneficiaires, :notifier_cc
    remove_column :beneficiaires, :beneficiaire_id
    rename_table :beneficiaires, :recipients

    rename_column :clients, :beneficiaires_count, :recipients_count
    rename_column :demandes, :beneficiaire_id, :recipient_id
    rename_column :phonecalls, :beneficiaire_id, :recipient_id
  end

  def self.down
    # ActiveRecord::IrreversibleMigration
  end
end
