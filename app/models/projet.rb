class Projet < ActiveRecord::Base
  has_many :taches
  has_and_belongs_to_many :ingenieurs
  has_and_belongs_to_many :beneficiaires
  has_and_belongs_to_many :logiciels


  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on)$/ || c.name == inheritance_column } 
  end


  def to_s
    self.resume
  end
end
