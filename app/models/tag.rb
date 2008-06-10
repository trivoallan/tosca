require 'vendor/plugins/acts_as_taggable_on_steroids/lib/tag.rb'
class Tag 
  
  belongs_to :user
  belongs_to :competence
  belongs_to :contract


  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def self.get_generic_tag
    return Tag.find(:all, :conditions => ["competence_id IS NULL and contract_id IS NULL"] )
  end

  def self.get_competence_tag (competences = nil)
    if competences.nil?
      conditions = ["competence_id IS NOT NULL"]
    else
      conditions = ["competence_id IN (?) ", competences ]
    end
    return Tag.find( :all, :conditions => conditions )
  end

  def self.get_contract_tag (contracts = nil)
    if contracts.nil?
      conditions = ["contract_id IS NOT NULL"]
    else
      conditions = ["contract_id IN (?) ", contracts ]
    end
    return Tag.find( :all, :conditions => conditions )
  end

end
