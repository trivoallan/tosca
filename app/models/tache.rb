#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Tache < ActiveRecord::Base
  belongs_to :projet, :counter_cache => true
  belongs_to :auteur, :class_name => 'Identifiant', :foreign_key => 'auteur_id'
  belongs_to :responsable, :class_name => 'Ingenieur', :foreign_key => 'responsable_id'

  belongs_to :etape

  acts_as_list :scope => :responsable

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|position|deadline)$/ || c.name == inheritance_column } 
  end

  def deadline_formatted
    d = @attributes['deadline']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]}"
  end
end
