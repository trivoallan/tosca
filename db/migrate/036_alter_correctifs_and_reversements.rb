class AlterCorrectifsAndReversements < ActiveRecord::Migration

  # TODO : datetime ou timestamp ? 

  # fusion des reversements et des correctifs
  # - on garde la possibilité d'avoir plusieurs urls de reversement : ajout d'une table urlreversements
  # - on découple les interactions
  def self.up

    # on recupère la plupart des champs des reversements : on les fusionne aux correctifs
    add.column :correctifs, :reverse_le, :timestamp
    add.column :correctifs, :description_fonctionnelle, :text, :default => "", :null => false
    add.column :correctifs, :updated_on, :timestamp
    add.column :correctifs, :etatreversement_id, :integer, :default => 0, :null => false
    add.column :correctifs, :cloture_le, :datetime

    # on a plus besoin de la table reversements
    # la liaison n'existe donc plus entre correctifs et interactions
    rename_table :reversements :old_reversements
    #drop_table :reversements

    # on recupère alors quelques champs des interactions
    add.column :correctifs, :logiciel_id, :integer, :default => 0, :null => false
    add.column :correctifs, :ingenieur_id, :integer, :null => false

    # l'url était jusqu'alors stockée dans l'interaction
    create_table :urlreversements, :force => true do |t|
      t.column :correctif_id, :integer, :default => 0, :null => false
      t.column :valeur, :string, :default => "", :null => false
    end

    # on ajoute la notion de type de contribution
    add.column :correctifs, :typecontribution_id, :integer, :default => 0, :null => false

    # on distingue les différents types de contribution
    create_table :typecontributions, :force => true do |t|
      t.column :nom, :string, :default => "", :null => false
      t.column :description, :text, :default => "", :null => false
    end    
    Typecontribution.create :nom => "Correction", :description => "Patch correctif"
    Typecontribution.create :nom => "Evolution", :description => "Patch amélioratif"

  end

  def self.down

    remove.column :correctifs, :reverse_le
    remove.column :correctifs, :description_fonctionnelle
    remove.column :correctifs, :updated_on
    remove.column :correctifs, :etatreversement_id
    remove.column :correctifs, :cloture_le

    rename_table :old_reversements :reversements
    #create_table "reversements", :force => true do |t|
    #  t.column "created_on", :timestamp
    #  t.column "accepte", :boolean, :default => true, :null => false
    #  t.column "commentaire", :text, :default => "", :null => false
    #  t.column "updated_on", :timestamp
    #  t.column "correctif_id", :integer, :default => 0, :null => false
    #  t.column "interaction_id", :integer, :default => 0, :null => false
    #  t.column "etatreversement_id", :integer, :default => 0, :null => false
    #  t.column "cloture", :datetime
    #end
    #add_index "reversements", ["correctif_id"], :name => "reversements_correctif_id_index"
    #add_index "reversements", ["interaction_id"], :name => "reversements_interaction_id_index"

    remove.column :correctifs, :logiciel_id
    remove.column :correctifs, :ingenieur_id
    remove.column :correctifs, :typecontribution_id

    drop_table :urlreversements
    drop_table :typecontributions

  end

end
