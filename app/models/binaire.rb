class Binaire < ActiveRecord::Base
  belongs_to :correctif
  file_column :fichier

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|^fichier)$/ || c.name == inheritance_column }     
  end

end
