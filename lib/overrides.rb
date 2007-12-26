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
module ActionView::Helpers::UrlHelper
  # this link_to is a specialised one which only returns a link
  # if the user is connected and has the right access to the ressource
  # requested. See public_link_to for everyone links.
  def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    action = nil
    return nil unless options
    if html_options
      case html_options[:method]
        when :delete
        action = 'destroy'
        when :put
        action = 'update'
      end
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    # With the hack on the named route, we have a nil url if authenticated user
    # does not have access to the page. See the hack to define_url_helper
    # for more information

    user = session[:user]
    unless url.blank? or user.nil?
      if options.is_a?(Hash) and options.has_key? :action
        required_perm = '%s/%s' % [ options[:controller] || controller.controller_name,
                                    options[:action] ]
        return nil unless user.authorized?(required_perm)
      end
      if action and options.is_a? String
        # No '/' here, since we have it with the grepped part of the url.
        # [/[^\/]*\/\d+$/] => a string without a '/', a '/' and an id
        required_perm = '%s%s' % [ url.scan(/([^\/]*)\/\d+$/).first.first, action ]
        return nil unless user.authorized?(required_perm)
      end
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


    # By convention, all tosca records have or implements a 'name' method,
    # used mainly for displaying and selecting them. It's also their default
    # to_s implementation, even if it's free to specialize it when needed.
    def to_s
      name
    end

    # It's the more common select applied, mainly for select box.
    # It returns the names and id, ready to be displayed
    def self.find_select(options = {})
      options.update(:select => 'id, name')
      options[:order] ||= "#{self.table_name}.name ASC"
      self.find(:all, options)
    end

    # Same as #find_select, but returns only active objects
    def self.find_active4select(options = {})
      options[:select] = 'id, name'
      table_name = self.table_name
      if options.has_key? :conditions
        options[:conditions] += " AND #{table_name}.inactive = 0"
      else
        options[:conditions] = "#{table_name}.inactive = 0"
      end
      options[:order] ||= "#{table_name}.name ASC"
      self.find(:all, options)
    end


    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def updated_on_formatted
      d = read_attribute :updated_on
      (d ? "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}" : '-')
    end

    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def created_on_formatted
      d = read_attribute :created_on
      (d ? "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}" : '-')
    end
  end
end


#To have homemade message-id in mails
module TMail
  class Mail
    def ready_to_send
      delete_no_send_fields
      #The only thing to comment.
      #add_message_id
      add_date
    end
  end
end
