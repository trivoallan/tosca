#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
Date::MONTHS = { 'Janvier' => 1, 'Février' => 2, 'Mars' => 3, 'Avril' => 4, 'Mai' => 5, 'Juin' => 6, 'Juillet' => 7, 'Août' => 8, 'Septembre'=> 9, 'Octobre' =>10, 'Novembre' =>11, 'Décembre' =>12 }
Date::DAYS = { 'Lundi' => 0, 'Mardi' => 1, 'Mercredi' => 2, 'Jeudi'=> 3, 'Vendredi' => 4, 'Samedi' => 5, 'Dimanche' => 6 }
Date::ABBR_MONTHS = { 'Jan' => 1, 'Fév' => 2, 'Mar' => 3, 'Avr' => 4, 'Mai' => 5, 'Juin' => 6, 'Juil' => 7, 'Aoû' => 8, 'Sep' => 9, 'Oct' =>10, 'Nov' =>11, 'Déc' =>12 }
Date::ABBR_DAYS = { 'lun' => 0, 'mar' => 1, 'mer' => 2, 'jeu' => 3, 'ven' => 4, 'sam' => 5, 'dim' => 6 }
Date::MONTHNAMES = [nil] + %w(Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre )
Date::DAYNAMES = %w(Lundi Mardi Mercredi Jeudi Vendredi Samedi Dimanche )
Date::ABBR_MONTHNAMES = [nil] + %w(Jan Fév Mar Avr Mai Juin Juil Aoû Sep Oct Nov Déc)
Date::ABBR_DAYNAMES = %w(lun mar mer jeu ven sam dim)


Date::ABBR_MONTHS_LSTM = { 0 => 'jan', 1 => 'fév', 2 => 'mar', 3 => 'avr', 4 => 'mai', 5 => 'juin', 6 => 'juil', 7 => 'aoû', 8 => 'sep', 9 => 'oct', 10 => 'nov', 11 => 'déc' }

class Time
  alias :strftime_nolocale :strftime
  
  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, Date::DAYNAMES[self.wday])
    format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
    self.strftime_nolocale(format)
  end
end

class Array
   def sum 
    inject( nil ) { |sum,x| sum ? sum+x : x }
   end
end

module ActiveRecord
  class Base

    def self.find_select(options = {})
      options.update(:select => 'id, nom', :order => 'nom ASC')
      self.find(:all, options)
    end

    def updated_on_formatted
      d = @attributes['updated_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
    end

    def created_on_formatted
      d = @attributes['created_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
    end
  end
end

module ActionController
  def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    "<a href=\"#{url}\"#{tag_options}>Yeah ! #{name || url}</a>"
 end
end
