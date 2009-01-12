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
class HbtmBetweenContractsAndRecipients < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_one :beneficiaire
    has_one :ingenieur
    has_and_belongs_to_many :contracts
  end
  class Ingenieur < ActiveRecord::Base
    has_and_belongs_to_many :contracts
    belongs_to :user, :dependent => :destroy
  end
  class Beneficiaire < ActiveRecord::Base
    belongs_to :client
    belongs_to :user, :dependent => :destroy
  end
  class Client < ActiveRecord::Base
    has_many :contracts
  end
  class Contract < ActiveRecord::Base
    belongs_to :client
  end

  # Move contracts to user, since it's now the same
  # for Recipient AND Engineers.
  def self.up
    create_table :contracts_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :contract_id, :integer
    end
    add_index :contracts_users, :user_id
    add_index :contracts_users, :contract_id

    Beneficiaire.all.each {|b|
      b.user.contracts = b.client.contracts
      b.user.save
    }
    Ingenieur.all.each { |i|
      i.user.contracts = i.contracts
      i.user.save
    }
    drop_table :contracts_ingenieurs
  end

  def self.down
    create_table :contracts_ingenieurs, :id => false do |t|
      t.column :ingenieur_id, :integer
      t.column :contract_id, :integer
    end
    add_index :contracts_ingenieurs, :ingenieur_id
    add_index :contracts_ingenieurs, :contract_id

    Ingenieur.all.each { |i|
      i.contracts = i.user.contracts
      i.save
    }
    drop_table :contracts_users
  end
end
