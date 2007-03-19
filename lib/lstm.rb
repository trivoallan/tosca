#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

#module Lstm

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
  def time_in_french_words(distance_in_seconds, dayly_time = 24)
    return '-' unless distance_in_seconds.is_a? Numeric and distance_in_seconds > 0

    distance_in_minutes = ((distance_in_seconds.abs)/60).round
    jo = dayly_time * 60 # in minutes
    mo = 30 * jo # in minutes
    demi_jo_inf = (jo / 2) - 60
    demi_jo_sup = (jo / 2) + 60
    out = ''

    case distance_in_minutes
    when 0 : out << '-'
    when 0..1 then 
      out << (distance_in_minutes==0) ? "moins d'une minute" : '1 minute'
    when 2..45      then 
      out << "#{distance_in_minutes} minutes"
    when 46..90     then 
      out << 'environ 1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..jo   then 
      out << "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
    when (demi_jo_inf+1)..demi_jo_sup
      out << "1 demie-journée"
    when jo..(1.5*jo)
      out << "1 jour"
    # à partir de 1.5 inclus, le round fait 2 ou plus : pluriel
    when (1.5*jo)..mo
      out << "#{(distance_in_minutes / jo).round} jours"
    when mo..(1.5*mo)
      out << "1 mois"
    else        
      out << "#{(distance_in_minutes / mo).round} mois"
    end
    out << " ouvré(s)" if (dayly_time!=24 and distance_in_minutes!=0)
    out
  end

#end
