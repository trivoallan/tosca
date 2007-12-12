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
  # Le deuxième paramètre peut être un nombre ou un booléen.
  #   Si c'est un nombre, ca indique le nombre d'heures dans une journée ouvrée
  #   Si c'est un booleén à true, ça indique que les journées font 24 heures et sont ouvrées
  #   Si il n'y a rien, les journées font 24 heures et ne sont pas ouvrées
  #
  # TODO : avoir un rake test
  # en attendant : ca passe avec
  # Lstm.time_in_french_words(15.hours, 5)
  # Lstm.time_in_french_words(13.hours, 5)
  # Lstm.time_in_french_words(10.hours, 5)
  # Lstm.time_in_french_words(2.days + 10.hours)
  # Lstm.time_in_french_words(0.5.days, true)
  def self.time_in_french_words(distance_in_seconds, dayly_time = 24)
    return '-' unless distance_in_seconds.is_a? Numeric and distance_in_seconds > 0
    return '-' unless dayly_time == true or (dayly_time > 0 and dayly_time < 25)
    ouvre = (dayly_time != 24 ? true : false)
    if (dayly_time == true)
      dayly_time = 24
      ouvre = true
    end

    distance_in_minutes = ((distance_in_seconds.abs)/60).round
    jo = dayly_time * 60 # jour ouvre en minutes
    mo = 30 * jo # mois ouvre en minutes
    demi_jo_inf = (jo/2) - 60
    demi_jo_sup = (jo/2) + 60
    out = ''
    plural = false
    male = false

    case distance_in_minutes
    when 0..1
      out << ((distance_in_minutes==0) ? "moins d'une minute" : '1 minute')
    when 2..45
      out << "#{distance_in_minutes} minutes"
      plural = true
    when 46..90
      out << '1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..(jo-60)
      out << "#{(distance_in_minutes.to_f / 60.0).round} heures"
      plural = true
    when (demi_jo_inf+1)..demi_jo_sup
      out << "1 demie-journée"
    # TODO : C'est pas dry
    when (jo-60)..(jo+60)
      out << '1 jour'
      male = true
    when (jo*2)+60..(jo*2-60)
      out << '2 jours'
      plural = true
      male = true
    when (jo*3)+60..(jo*3-60)
      out << '3 jours'
      plural = true
      male = true
    when jo..(3*jo)
      nb_jours = (distance_in_minutes / jo).floor
      nb_heures = ((distance_in_minutes - (nb_jours*jo))/60).round
      out << pluralize(nb_jours, "jour").to_s
      male = true
      if nb_heures > 0
        out << " et #{self.pluralize(nb_heures, "heure")}"
        plural = true
      end
    when (3*jo)..mo
      out << "#{(distance_in_minutes / jo).round} jours"
      male = true
      plural = true
    when mo..(1.5*mo)
      out << "1 mois"
      male = true
    else
      out << "#{(distance_in_minutes / mo).round} mois"
      male = true
      plural = true
    end
    if ouvre and distance_in_minutes!=0
      out << " ouvré"
      out << "e" unless male
      out << "s" if plural
    end
    out
  end

end
