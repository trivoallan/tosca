class Urlcontribution2Contributionurl < ActiveRecord::Migration
  def self.up
    rename_table :urlreversements, :contributionurls
  end

  def self.down
    rename_table :contributionurls, :urlreversements
  end
end
