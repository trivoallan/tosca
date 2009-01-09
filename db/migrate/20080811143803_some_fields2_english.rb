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
class SomeFields2English < ActiveRecord::Migration
  def self.up
    rename_column :contracts, :mailinglist, :internal_ml
    rename_column :changelogs, :date_modification, :modification_date
    rename_column :changelogs, :nom_modification, :name #Be more Tosca compatible
    rename_column :changelogs, :text_modification, :modification_text

    rename_column :commitments, :contournement, :workaround

    drop_table :communautes

    rename_column :contracts, :ouverture, :start_date
    rename_column :contracts, :cloture, :end_date
    rename_column :contracts, :astreinte, :obligation
    rename_column :contracts, :veille_technologique, :technological_survey
    rename_column :contracts, :heure_ouverture, :opening_time
    rename_column :contracts, :heure_fermeture, :closing_time
    rename_column :contracts, :commercial_id, :salesman_id

    #Do not do in the 08000linux branch ?
    remove_column :contracts, :chrono
  end

  def self.down
    rename_column :changelogs, :modification_date, :date_modification
    rename_column :changelogs, :name, :nom_modification
    rename_column :changelogs, :modification_text, :text_modification
    rename_column :commitments, :workaround, :contournement

    create_table "communautes", :force => true do |t|
      t.string   "name"
      t.text     "description",                 :null => false
      t.string   "url",         :default => "", :null => false
      t.datetime "created_on",                  :null => false
      t.datetime "updated_on",                  :null => false
    end

    rename_column :contracts, :start_date, :ouverture
    rename_column :contracts, :end_date, :cloture
    rename_column :contracts, :obligation, :astreinte
    rename_column :contracts, :technological_survey, :veille_technologique
    rename_column :contracts, :opening_time, :heure_ouverture
    rename_column :contracts, :closing_time, :heure_fermeture
    rename_column :contracts, :salesman_id, :commercial_id
    rename_column :contracts, :internal_ml, :mailinglist

    add_column :contracts, :chrono, :integer

  end
end
