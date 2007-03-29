#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################



module Lstm

  extend ActionView::Helpers::TextHelper

  # DUPLICATED FROM model/demande.rb
  # Renvoi l'expression, en francais, d'une durée passee en seconde
  # Un deuxieme argument, optionnel, permet de préciser le temps ouvré d'un jour
  #
  # Reports the approximate distance in time between two Time objects or integers. 
  # For example, if the distance is 47 minutes, it'll return
  # "about 1 hour". See the source for the complete wording list.
  #
  # Integers are interpreted as seconds. So,
  # <tt>distance_of_time_in_words(50)</tt> returns "less than a minute".
  #
  # Set <tt>include_seconds</tt> to true if you want more detailed approximations if distance < 1 minute
  def self.time_in_french_words(distance_in_seconds, dayly_time = 24)
    return '-' unless distance_in_seconds.is_a? Numeric and distance_in_seconds > 0

    distance_in_minutes = ((distance_in_seconds.abs)/60).round
    jo = dayly_time * 60 # in minutes
    mo = 30 * jo # in minutes
    demi_jo_inf = (jo / 2) - 60
    demi_jo_sup = (jo / 2) + 60
    out = ''
    plural = false

    case distance_in_minutes
    when 0..1 
      out << ((distance_in_minutes==0) ? "moins d'une minute" : '1 minute')
    when 2..45
      out << "#{distance_in_minutes} minutes"
      plural = true
    when 46..90
      out << 'environ 1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..jo
      out << "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
      plural = true
    when (demi_jo_inf+1)..demi_jo_sup
      out << "1 demie-journée"
    when jo..(3*jo)
      nb_jours = (distance_in_minutes / jo).floor
      nb_heures = (jo - nb_jours)/60.round
      out << pluralize(nb_jours, "jour").to_s
      if nb_heures > 0
        out << " et #{self.pluralize(nb_heures, "heure")}"
        plural = true
      end
    when (3*jo)..mo
      out << "#{(distance_in_minutes / jo).round} jours"
      plural = true
    when mo..(1.5*mo)
      out << "1 mois"
    else
      out << "#{(distance_in_minutes / mo).round} mois"
      plural = true
    end
    if dayly_time!=24 and distance_in_minutes!=0
      out << " ouvré"
      out << "s" if plural
    end
  end

end
