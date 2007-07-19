#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################


# MLO : ça permet de virer le warning comme quoi on override :)
# TODO : voir comment faire ça avec ruby gettext
$VERBOSE=nil
class Date
    MONTHS = { 'Janvier' => 1, 'Février' => 2, 'Mars' => 3, 'Avril' => 4, 'Mai' => 5, 'Juin' => 6, 'Juillet' => 7, 'Août' => 8, 'Septembre'=> 9, 'Octobre' =>10, 'Novembre' =>11, 'Décembre' =>12 }
    DAYS = { 'Dimanche' => 0, 'Lundi' => 1, 'Mardi' => 2, 'Mercredi' => 3, 'Jeudi'=> 4, 'Vendredi' => 5, 'Samedi' => 6 }
    ABBR_MONTHS = { 'Jan' => 1, 'Fév' => 2, 'Mar' => 3, 'Avr' => 4, 'Mai' => 5, 'Juin' => 6, 'Juil' => 7, 'Aoû' => 8, 'Sep' => 9, 'Oct' =>10, 'Nov' =>11, 'Déc' =>12 }
    ABBR_DAYS = {'dim' => 0, 'lun' => 1, 'mar' => 2, 'mer' => 3, 'jeu' => 4, 'ven' => 5, 'sam' => 6}

    ABBR_MONTHS_LSTM = { 1 => 'jan', 2 => 'fév', 3 => 'mar', 4 => 'avr', 5 => 'mai', 6 => 'juin', 7 => 'juil', 8 => 'aoû', 9 => 'sep', 10  => 'oct', 11 => 'nov', 12 => 'déc' }

  def self.translate_strings(controller)
    @action_controller = controller
    eval %(
      def self._(string)
        @action_controller.instance_eval { gettext(string) }
      end
    )
     Date::DAYNAMES.replace [
       _('Sunday'), _('Monday'), _('Tuesday'), _('Wednesday'),
       _('Thursday'), _('Friday'), ('Saturday')
     ]
     Date::MONTHNAMES.replace [
       _('January'), _('February'), _('March'), _('April'), _('May'), _('June'), _('July'),
       _('August'), _('September'), _('October'), _('November'), _('December')
     ]

     Date::ABBR_DAYNAMES.replace [
       _("sun"), _("mon"), _("tue"),_("wed"),
       _("thu"), _("fri"),_("sat")
     ]
     Date::ABBR_MONTHNAMES.replace [
       _('Jan'), _('Feb'),_('Mar'), _('Apr'), _('May'), _('Jun'), _('Jul'),
       _('Aug'), _('Sep'), _('Oct'), _('Nov'), _('Dec')
     ]
  end
end



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
   #   [ 4, 5 ].sum
   #      9
   def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
   end
end

class String
  # this convenience method search an url in a string and add the "http://" needed
  # RFC sur les URLS : link:"http://rfc.net/rfc1738.html"
  # Made from this regexp : link:"http://www.editeurjavascript.com/scripts/scripts_formulaires_3_250.php"
  #
  # It works with :
  #  "www.google.com"
  #  "http://www.google.com"
  #  "toto tutu djdjdjd google.com" >
  #  "toto tutu djdjdjd http://truc.machin.com/touo/sdqsd?tutu=1&machin google.com/toto/ddk?tr=1&machin"
  #TODO: A améliorer
  def urlize
    (self.gsub(/(\s+|^)[a-zA-Z]([\w-]{0,61}\w)?\.[a-zA-Z]([\w-]{0,61}\w)?(\.[a-zA-Z]([\w-]{0,61}\w)?)?/) { |s| " http://" + s.strip }).strip
  end

  # Small convenience method which replace each space by its unbreakable html
  # equivalent.
  #
  # Call it like this :
  #   "this is a test".unbreak
  #     this&nbsp;is&nbsp;a&nbsp;test"
  def unbreak
    self.gsub(' ', '&nbsp;')
  end

end

#Optimization des vues : plus '\n'
ActionView::Base.erb_trim_mode = '>'

# This module is overloaded in order to display link_to lazily
# and efficiently. It display links <b>only</b> if the user
# has the right access to the ressource.
module ActionView::Helpers::UrlHelper
  # this link_to is a specialised one which only returns a link
  # if the user is connected and has the right access to the ressource
  # requested. See public_link_to for everyone links.
  def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    required_perm = '%s/%s' % [ options[:controller] || controller.controller_name,
                                options[:action] || controller.action_name ]
    user = session[:user]
    if !user.nil? and user.authorized? required_perm then
      "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
    else
      nil
    end
  end

  # this link_to display a link whatever happens, to all the internet world
  def public_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
  end
end


# This module is overloaded, mainly for performance
# and the scope stuff.
module ActiveRecord
  class Base
    # This <b>must</b> be called after each call of set_scope,
    # specified in each concerned model. See ApplicationController
    # and its around_filter for more information
    def self.remove_scope
      self.scoped_methods.pop
    end

    # It's the more common select applied, mainly for select box.
    # It returns the names and id, ready to be displayed
    def self.find_select(options = {})
      options.update(:select => 'id, nom')
      options[:order] ||= "#{self.table_name}.nom ASC"
      self.find(:all, options)
    end

    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def updated_on_formatted
      d = @attributes['updated_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
    end

    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def created_on_formatted
      d = @attributes['created_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}"
    end
  end
end


# This module is overloaded in order to have rails fitting more
# Tosca specific needs or specific improvments
module ActionController::Routing
  class RouteSet
    # this overloads allows to have REST routes for non-orm controllers
    class Mapper
      def without_orm(controller, actions, method = :get)
        actions.each { |action|
          self.send("#{action}_#{controller}", "#{controller};#{action}",
                    { :controller => controller, :action => action,
                      :conditions => { :method => method }})
        }
      end
    end


    class NamedRouteCollection
      # This overload permits to gain a factor 7 in performance of
      # url generation
      def define_url_helper(route, name, kind, options)
        selector = url_helper_name(name, kind)

        # The segment keys used for positional paramters
        segment_keys = route.segments.collect do |segment|
          segment.key if segment.respond_to? :key
        end.compact
        hash_access_method = hash_access_name(name, kind)

        @module.send :module_eval, <<-end_eval #We use module_eval to avoid leaks
          def #{selector}(*args)
            opts = if args.empty? || Hash === args.first
              args.first || {}
            else
              # allow ordered parameters to be associated with corresponding
              # dynamic segments, so you can do
              #
              #   foo_url(bar, baz, bang)
              #
              # instead of
              #
              #   foo_url(:bar => bar, :baz => baz, :bang => bang)
              args.zip(#{segment_keys.inspect}).inject({}) do |h, (v, k)|
                h[k] = v
                h
              end
            end

            # return a cached version of the url for the default one
            if opts.empty?
              @@#{selector}_cache ||= url_for(#{hash_access_method}(opts))
            else
              url_for(#{hash_access_method}(opts))
            end
          end
        end_eval
        @module.send(:protected, selector)
        helpers << selector
      end
    end
  end
end
