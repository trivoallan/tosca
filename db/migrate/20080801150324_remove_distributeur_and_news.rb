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
