class Contribution2english < ActiveRecord::Migration
  def self.up
    rename_column :contributions, :reverse_le, :contributed_on
    rename_column :contributions, :cloture_le, :closed_on
    rename_column :contributions, :synthese, :synthesis
    # this field was not used
    update("UPDATE contributions SET description = description_fonctionnelle")
    remove_column :contributions, :description_fontionnelle
  end

  def self.down
    rename_column :contributions, :contributed_on, :reverse_le
    rename_column :contributions, :closed_on, :cloture_le
    rename_column :contributions, :synthesis, :synthese
    add_column :contributions, :description_fontionnelle, :text
  end
end
