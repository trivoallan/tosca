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
class ImprovePackageVersioning < ActiveRecord::Migration
  class Paquet < ActiveRecord::Base
    belongs_to :logiciel
    belongs_to :contract, :counter_cache => true
    belongs_to :mainteneur

    has_many :changelogs, :dependent => :destroy
    has_many :binaires, :dependent => :destroy, :include => :version
    has_and_belongs_to_many :contributions
  end
  
  def self.up
    change_column :paquets, :version, :string,  :limit => 60, :default => "x",  :null => false
    change_column :paquets, :release, :string,  :limit => 60, :default => nil, :null => true
    Paquet.all.each do |p|
      p.update_attribute :release, nil if p.release == ''
    end
  end

  # no need for this one
  def self.down
  end
end
