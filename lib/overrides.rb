#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################


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
require 'action_controller/test_process' 
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
    
    # Not a really good way, we demux the url for reobtaining action & controller
    # In order to keep features of obtaining nil link when users do not have rights.
    # It's so silly. TODO : find a clever way, this is clearly a workaround.
    request = ActionController::TestRequest.new({}, {}, nil)
    method = ((html_options.nil? or html_options[:method].blank?) ? 'GET' : 
                  html_options[:method].to_s.upper )
    request.env["REQUEST_METHOD"] = method
    request.path = url
    ActionController::Routing::Routes.recognize(request)
    path = request.path_parameters
    required_perm = '%s/%s' % [ path[:controller], path[:action] ]

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
