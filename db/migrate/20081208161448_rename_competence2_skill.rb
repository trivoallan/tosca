class RenameCompetence2Skill < ActiveRecord::Migration
  def self.up
    rename_table :competences, :skills
    rename_table :competences_softwares, :skills_softwares
    
    rename_column :skills_softwares, :competence_id, :skill_id
    rename_column :knowledges, :competence_id, :skill_id
    rename_column :tags, :competence_id, :skill_id
  end

  def self.down
    rename_table :skills, :competences
    rename_table :skills_softwares, :competences_softwares
    
    rename_column :competences_softwares, :skill_id, :competence_id
    rename_column :knowledges, :skill_id, :competence_id
    rename_column :tags, :skill_id, :competence_id  
  end
end
