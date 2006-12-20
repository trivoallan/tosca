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

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def cloture_formatted
      d = @attributes['cloture']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
  end

end
