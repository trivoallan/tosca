#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Reversement < ActiveRecord::Base
  # le :include sert à specifier quel 
  # beneficiaire pourra consulter le reversement
  belongs_to :correctif
  belongs_to :interaction

  # le has_many :through ne marche pas sur :correctif
  # TODO : checker si en rails 1.2 ou + ca marche
  # sinon, mettre des boites à cocher client_id ?
  has_many :beneficiaires, :finder_sql => 
    'SELECT beneficiaires.* FROM beneficiaires INNER JOIN demandes ' +
    'ON beneficiaires.id=demandes.beneficiaire_id INNER JOIN correctifs ' +
    'ON demandes.correctif_id = correctifs.id INNER JOIN reversements ' +
    'ON correctifs.id=reversements.correctif_id ' + 
    "WHERE reversements.id = #{id}"

  #, :joins => 'INNER JOIN correctifs ON demandes.correctif_id = correctifs.id '

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

  # délai en jour
  def delai
    ( cloture - created_on )/(3600*24)
  end

end
