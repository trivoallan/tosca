class AlterCorrectifsAndReversements < ActiveRecord::Migration

  # fusion des reversements et des correctif
  def self.up
    # on recupère la plupart des champs des reversements et des interactions
    add.column :correctifs, :reverse_le, :datetime
    add.column :correctifs, :description_fonctionnelle, :text, :default => "", :null => false
    add.column :correctifs, :updated_on, :timestamp
    add.column :correctifs, :etatreversement_id, :integer, :default => 0, :null => false
    add.column :correctifs, :cloture_le, :datetime
    add.column :correctifs, :logiciel_id, :integer, :default => 0, :null => false
    add.column :correctifs, :ingenieur_id, :integer, :null => false

    # la liaison n'existe donc plus entre correctifs et interactions
    rename_table :reversements :old_reversements

    # on garde la possibilité d'avoir plusieurs urls de reversement : ajout d'une table urlreversements
    create_table :urlreversements, :force => true do |t|
      t.column :correctif_id, :integer, :default => 0, :null => false
      t.column :valeur, :string, :default => "", :null => false
    end

    # on ajoute la notion de type de contribution
    add.column :correctifs, :typecontribution_id, :integer, :default => 0, :null => false
    create_table :typecontributions, :force => true do |t|
      t.column :nom, :string, :default => "", :null => false
      t.column :description, :text, :default => "", :null => false
    end    
    Typecontribution.create :nom => "correction", :description => "Patch correctif"
    Typecontribution.create :nom => "évolution", :description => "Patch amélioratif"
  end

  def self.down
    remove.column :correctifs, :reverse_le
    remove.column :correctifs, :description_fonctionnelle
    remove.column :correctifs, :updated_on
    remove.column :correctifs, :etatreversement_id
    remove.column :correctifs, :cloture_le
    remove.column :correctifs, :logiciel_id
    remove.column :correctifs, :ingenieur_id

    # restauration de la table précédemment sauvegardée (cf self.up)
    rename_table :old_reversements :reversements

    drop_table :urlreversements
    drop_table :typecontributions
    remove.column :correctifs, :typecontribution_id
  end

end
