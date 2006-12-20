#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Interaction < ActiveRecord::Base
  belongs_to :logiciel, :counter_cache => true
  belongs_to :ingenieur, :counter_cache => true, :include => [:identifiant]
  has_one :reversement

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on)$/ || c.name == inheritance_column }     
  end

end
