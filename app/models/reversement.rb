#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Reversement < ActiveRecord::Base
  belongs_to :correctif
  belongs_to :interaction

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on)$/ || c.name == inheritance_column }     
  end

end
