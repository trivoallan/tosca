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
class Urlsoftware < ActiveRecord::Base
    belongs_to :software
  end

class Contributionurl < ActiveRecord::Base
    belongs_to :contribution
end

class CreateUrls < ActiveRecord::Migration
  
  def self.up
    create_table :hyperlinks do |t|
      t.string :name
      t.string :model_type
      t.integer :model_id
    end

    Urlsoftware.all.each do |url|
      u = Hyperlink.new({:model_type => "software",
        :model_id => url.software_id,
        :name => url.valeur
      })
      u.save
    end

    Contributionurl.all.each do |url|
      u = Hyperlink.new({:model_type => "contribution",
        :model_id => url.contribution_id,
        :name => url.valeur
      })
      u.save
    end

    drop_table :urlsoftwares
    drop_table :contributionurls
  end

  def self.down
    drop_table :hyperlinks
  end
end
