class RefactoringReversement < ActiveRecord::Migration
  def self.up
    add_column :reversements, :nom,
    :string, :null => true
    change_column :reversements, :accepte, 
      :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :reversements, :nom
  end
end

