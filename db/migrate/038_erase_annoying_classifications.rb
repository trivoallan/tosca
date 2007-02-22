#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class EraseAnnoyingClassifications < ActiveRecord::Migration
  def self.up
    add_column :logiciels, :groupe_id, :integer

    # lazy way
    logiciels = Logiciel.find(:all)
    logiciels.each { |l| 
      l.classifications.each { |classification|
        l.groupe_id = classification.groupe_id
        l.save
      }
    }
    rename_table :classifications, :old_classifications
    rename_table :bouquets, :old_bouquets

  end

  def self.down
    remove_column :logiciels, :groupe_id

    rename_table :old_classifications, :classifications
    rename_table :old_bouquets, :bouquets

  end
end
