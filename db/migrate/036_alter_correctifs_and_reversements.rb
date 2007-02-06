class AlterCorrectifsAndReversements < ActiveRecord::Migration

  # fusion des reversements et des correctif
  def self.up
    # on recupère la plupart des champs des reversements et des interactions
    add_column :correctifs, :reverse_le, :datetime
    add_column :correctifs, :description_fonctionnelle, :text, :default => "", :null => false
    add_column :correctifs, :updated_on, :timestamp
    add_column :correctifs, :etatreversement_id, :integer, :default => 0, :null => false
    add_column :correctifs, :cloture_le, :datetime
    add_column :correctifs, :logiciel_id, :integer, :default => 0, :null => false
    add_column :correctifs, :ingenieur_id, :integer, :null => false

    # la liaison n'existe donc plus entre correctifs et interactions
    rename_table :reversements, :old_reversements

    # on garde la possibilité d'avoir plusieurs urls de reversement : ajout d'une table urlreversements
    create_table :urlreversements, :force => true do |t|
      t.column :correctif_id, :integer, :default => 0, :null => false
      t.column :valeur, :string, :default => "", :null => false
    end

    # on ajoute la notion de type de contribution
    add_column :correctifs, :typecontribution_id, :integer, :default => 0, :null => false
    create_table :typecontributions, :force => true do |t|
      t.column :nom, :string, :default => "", :null => false
      t.column :description, :text, :default => "", :null => false
    end    
    Typecontribution.create :nom => "correction", :description => "Patch correctif"
    Typecontribution.create :nom => "évolution", :description => "Patch amélioratif"
  end

  def self.down
    remove_column :correctifs, :reverse_le
    remove_column :correctifs, :description_fonctionnelle
    remove_column :correctifs, :updated_on
    remove_column :correctifs, :etatreversement_id
    remove_column :correctifs, :cloture_le
    remove_column :correctifs, :logiciel_id
    remove_column :correctifs, :ingenieur_id

    # restauration de la table précédemment sauvegardée (cf self.up)
    rename_table :old_reversements, :reversements

    drop_table :urlreversements
    drop_table :typecontributions
    remove_column :correctifs, :typecontribution_id
  end

end
