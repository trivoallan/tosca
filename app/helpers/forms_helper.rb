#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# This module contains all the stuff related to forms.
module FormsHelper

  PROMPT_SELECT = { :prompt => '» ' }

  ### Forms ##################################################

  # Collection doit contenir des objects qui ont un 'id' et un 'name'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # L'option :size permet une mise en colonne
  # Ex : hbtm_check_box( @software.competences, @competences, 'competence_ids')
  def hbtm_check_box( objectcollection, collection, name , options={})
    return '' if collection.nil? || collection.empty?
    objects = objectcollection.collect { |c| [ c.name, c.id ] }
    objects = Hash[*objects.flatten.reverse]
    out = '<table class="full"><tr>' and count = 1
    options_size = options[:size]
    length = collection.size
    name_w3c = name.gsub(/[^a-z1-9]+/i, '_')
    for data in collection
      value = (data.is_a?(ActiveRecord::Base) ? data.name : data.first)
      id = (data.is_a?(ActiveRecord::Base) ? data.id : data.last)
      out << "<td class=\"#{cycle('odd', 'even')}\">"
      out <<  "<label for=\"#{name_w3c}_#{id}\">"
      out <<   "<input id=\"#{name_w3c}_#{id}\" type=\"checkbox\" "
      out <<      "name=\"#{name}[]\" value=\"#{id}\" "
      out <<      'checked="checked" ' if objects.has_key?(id)
      out <<   "/> #{value}"
      out <<  "</label>"
      out << "</td>"
      if options_size
        if (count % options_size == 0) and length > count
          out << "</tr><tr>"
          # allows to prettify like a chess the checkbox
          cycle('odd','even') if (options_size % 2) == 0
        end
        count += 1
      end
    end
    out << '</tr></table>'
    out << "<input id=\"#{name_w3c}_\" type=\"hidden\" name=\"#{name}[]\" value=\"\" >"
  end

  # Collection have to contain object which respond to 'id' and 'name'
  # Object & Param allow to keep n' display the selected one
  # In the options, you have :
  #   * :size => Number of columns before an end of line (<br />)
  # Ex : hm_radio_button( 'user', 'role_id', @roles, :size => 3)
  def hm_radio_button( object, param, collection, options = {})
    out = ''
    return out if collection.nil?
    options_size = options[:size]
    count = 1
    for data in collection
      out << radio_button(object, param, data.last)
      out << "<label for=\"#{object}_#{param}_#{data.last}\">#{data.first}</label> "
      if options_size
        out << '<br />' if (count % options_size == 0)
        count += 1
      end
    end
    out
  end

  # select_onchange(@clients, @current_client, 'client')
  # options
  # :width limit size of displayed characters
  # :title 1st element of the list. Default is the selector '» '
  # :first_value, first_line :
  #   1st content line to display, after the title.
  #    It <strong>must</strong> respond_to? :name & :id
  # :onchange javascript's action
  # :size height of the select
  def select_onchange(list, default, name, options = {})
    title = [[options[:title] || '» ', '' ]]
    options[:onchange] ||= 'this.form.submit();'
    options[:name] ||= name

    if options.has_key?(:first_value)
      options[:first_name] ||= options[:first_value].name
      title.push([options[:first_name] , options[:first_value].id ])
    end
    list = title.concat(list || [])

    default_value = (default.is_a?(Numeric) ? default : 0)
    select = options_for_select(list, default_value)
    content_tag :select, select, options
  end

  def select_empty(object, method, choices, options = {}, html_options = {})
    title = [[ '» ', '' ]]
    select(object, method, title.concat(choices), options, html_options)
  end

  # Fields est un tableau du formulaire, en 2 colonnes
  # mutualisé pour le formulaire et l'affichage
  # Les éléments doivent être affichable par to_s
  # si l'une des colonne est à nil, la ligne est fusionnée
  # /!\ Do not call it anymore /!\
  def show_table_form(fields, options = {})
    fields.compact!
    result = ''
    style = "class='#{options[:class]}'" if options.has_key? :class
    result << "<table #{style}>"
    fields.each { |f|
      title, field = f.first, f.last
      unless title.nil? and field.nil?
        result << '<tr>'
        if field.nil?
          result << '<td colspan="2">' << title << '</td>'
        elsif title.nil?
          result << '<td colspan="2">' << field << '</td>'
        else
          result << "<td>#{title}</td>"
          result << "<td>#{field}</td>"
        end
        result << '</tr>'
      end
    }
    result << '</table>'
  end

  # Display a quick form field to go to a ticket
  # TODO : use yield to include what we want in the form
  # Call it like :
  #  if session[:user] && session[:user].authorized?('issues/index')
  #    out << form_tag(issues_path)
  #    out <<  search_issue_field
  #    out << end_form_tag
  #  end
  def search_issue_field
    text_field('numero', '', :size => 3,
      :title => _("Quick access to an issue : type the issue number here"))
  end
  alias_method :search_issue, :search_issue_field

  # Create the original auto_complete field
  def auto_complete(object, method, tag_options = {}, completion_options = {})
    completion_options[:skip_style] = true
    text_field_with_auto_complete(object, method, tag_options)
  end

  # Create the auto_complete field wich insert the choice after click to the table.
  def auto_complete_list(object, method, objectcollection, name, tag_options = {}, completion_options = {})
    @name =  name
    out = "<table>"
    out << "<tr><td cilspan=\"2\">"
    tag_options[:value]= _("Search") + "..."
    tag_options[:onfocus] = "$('#{object}_#{method}').value = \"\" "
    tag_options[:onblur] = "$('#{object}_#{method}').value = \"#{_("Search") + "..."}\""
    completion_options[:skip_style] = true
    completion_options[:indicator] = "spinner_#{object}_#{method}"
    out << "<label>" << _("Add")<< " "<< _(object.to_s) << "</label>"
    out << "</td></tr><tr><td>"
    out << text_field_with_auto_complete(object, method, tag_options, completion_options)
    field = "#{object}_#{method}"
    @field = field
    spinner = image_tag("spinner.gif", :id => "spinner_#{field}",:style=> "display: none;")
    out << %Q{</td><td width="20">#{spinner}</td></tr>}
    out << "</table>"
    out << "<ul>"
    objectcollection.each do |c|
      @value = c.id
      @html_id = "li_#{@field}_#{@value}"
      @content = "#{c.name} #{delete_button(@html_id)}"
      out << "#{render :partial => 'applications/auto_complete_insert'}"
    end
    # We need an empty one, which is used to insert
    @content = ""
    @value = ""
    @html_id = "li_#{@field}_"
    @new_record = true
    out << "#{render :partial => 'applications/auto_complete_insert'}"
    out << "</ul>"
  end

  # Create the choice list for auto_compete
  def auto_complete_choice( object, method, collection, name , options={})
    return '' if collection.nil? || collection.empty?
    @field = "#{object}_#{method}"
    @name = name
    content_tag(:ul, collection.map do |c|
      @value = c.id
      @html_id = "li_#{@field}_#{@value}"
      @content = "#{c.name} #{delete_button(@html_id)}"
      html_id_empty = "li_#{@field}_"
      @new_record = true
      js_call = "if ($('#{@html_id}')==null){" << update_page do |page|
          page.insert_html :before, html_id_empty, :partial => 'applications/auto_complete_insert'
          page.visual_effect(:appear, @html_id)
        end << "} tosca_reset(\"#{@field}\")"
      out = link_to_function(c.name, js_call)
      content_tag(:li, out)
    end )
  end

  # Apply a fade effect and delete the html element
  def delete_button(id)
    link_to_function(StaticImage::delete, %Q{tosca_remove("#{id}")})
  end

end
