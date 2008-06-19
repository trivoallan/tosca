class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
      t.column :user_id, :integer
      t.column :competence_id, :integer
      t.column :demande_id, :integer
    end

    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string

      t.column :created_at, :datetime
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
