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
class RemoveDistributeurAndNews < ActiveRecord::Migration
  def self.up
    drop_table :distributeurs
    drop_table :news
  end

  def self.down
    create_table "news", :force => true do |t|
      t.column "subject",      :string,   :default => "", :null => false
      t.column "source",       :string,   :default => "", :null => false
      t.column "body",         :text
      t.column "created_on",   :datetime
      t.column "updated_on",   :datetime
      t.column "ingenieur_id", :integer,                  :null => false
      t.column "client_id",    :integer
      t.column "logiciel_id",  :integer,                  :null => false
    end
    add_index "news", ["ingenieur_id"]
    add_index "news", ["logiciel_id"]
    add_index "news", ["subject"]

    create_table "distributeurs", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

  end
end
