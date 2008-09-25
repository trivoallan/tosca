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
module RequestsHelper

  # Display a link to a request
  # Options
  #  * :show_id display the id
  #  * :icon_severite display severity icon
  #  * :limit display only :limit caracters
  def link_to_request(request, options = {})
    return '-' unless request
    text = options[:text]
    if text.nil?
      limit = options[:limit] || 50
      text = ''
      text << "##{request.id} " if options.has_key? :show_id
      text << "#{StaticImage::severite(request)} " if options.has_key? :icon_severite #TODO
      text << truncate(request.resume, limit)
    end
    link_to text, request_path(request)
  end

  def public_link_to_status_legend
    public_link_to(_("Legend of statutes"), statuts_path, NEW_WINDOW)
  end

  # Display a link to the software or version or release
  # of a request
  def link_to_request_software(request)
    return '-' unless request
    path = ""
    path = logiciel_path(request.logiciel) if request.logiciel
    path = version_path(request.version) if request.version
    path = release_path(request.release) if request.release
    link_to request.full_software_name, path
  end

  # TODO : explain what does this function
  # TODO : teach the author how to make it understandable
  # TODO : give an example
  # TODO : think about replacing case/when by if/else
  def display(donnee, column)
    case column
    when 'workaround','correction'
      display_days donnee.send(column)
    else
      donnee.send(column)
    end
  end

  def render_table(options)
    render :partial => "report_table", :locals => options
  end

  def render_detail(options)
    render :partial => "report_detail", :locals => options
  end

  # Display more nicely change to history table
  # Use it like :
  #  <%= display_history_changes(request.ingenieur_id, old_ingenieur_id, Ingenieur) %>
  def display_history_changes(field, old_field, model)
    if field
      if old_field and old_field == field
        '<center></center>'
      else
        model.find(field).name
      end
    else
      '<center>-</center>'
    end
  end

  # Used to call remote ajax action
  # Call it like :
  #  <% options = { :update => 'request_tab',
  #     :url => { :action => nil, :id => @request_tosca.id },
  #     :before => "Element.show('spinner')",
  #     :success => "Element.hide('spinner')" } %>
  #  <%= link_to_remote_tab('Description', 'ajax_description', options) %>
  def link_to_remote_tab(name, action_name, options)
    if (action_name != controller.action_name)
      link_to_remote name, options
    else
      link_to_remote name, options, :class => 'active'
    end
  end

  def link_to_new_request(arg)
    options = arg ? new_request_path(arg) : new_request_path
    link_to image_create(_('New request')), options
  end

  # Link to access a ticket
  def link_to_comment(ar)
      link_to StaticImage::view, request_path(ar)
  end

  def link_to_unlink_contribution( demand_id )
    link_to(_('Unlink the contribution'),
            unlink_contribution_request_path(demand_id),
            :method => :post)
  end

  # Display a css bar for graphic representation of a ticket timeline
  # Need adequat CSS stylesheet
  def show_cns_bar(request)
    #done, limit = 0, 100
    return '' unless request.is_a?(Request)
    done = request.temps_correction
    limit = request.delais_correction
    return '' unless done.is_a?(Numeric) && limit.is_a?(Numeric) && done <= limit

    out = ''
    progress = (100*(done.to_f / limit.to_f)).round
    remains = (100 - progress)
    out << '<span class="progress-border">'
    out << '  <div class="progress-correction tooltip" style="width: '+progress.to_s+'%;" title="'+progress.to_s+'%  écoulé"> </div>'
    out << '  <div class="progress-restant tooltip" style="width: '+remains.to_s+'%;" title="'+remains.to_s+'%  restant"> </div>'
    out << '</span>'
  end

  # TODO : Some patches can be refused by the community, and this
  # method does not treat this case.
  def link_to_request_contribution(contribution)
    return '' unless contribution
    link = link_to _('patch'), contribution_path(contribution)
    (contribution.closed_on? ?
        _("The %s has been accepted by the community") % link :
        _("The %s has been submitted by the community") % link)
  end

  # TODO : beaucoup trop de copier coller, c'est honteux !
  # TODO/MLO : me taper sur les doigts et faire une version propre
  # begining of factorisation in logiciels_helper
  def remote_link_to_active_request
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => requests_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=1; #{remote_function(ajax_call)}"
    link_to_function(_('Active requests'), js_call,
                     _('show requests waiting to be processed'))
  end

  def remote_link_to_dead_request
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => requests_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=-1; #{remote_function(ajax_call)}"
    link_to_function(_('Finished requests'), js_call,
                     _('show requests that were processed'))
  end

  def remote_link_to_all_request
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => requests_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=0; #{remote_function(ajax_call)}"
    link_to_function(_('All the requests'), js_call,
                     _('show all the requests'))
  end

  #usage : <tr <%= tr_attributes("../requests/comment/#{demand.id}")%> >
  def tr_attributes(href)
    "class=\"#{cycle('even', 'odd')}\" " <<
      "onclick=\"window.location.href='#{href}'\""
  end


  def display_commitment(req)
    return '-' unless req
    commitment = req.commitment
    if commitment
      "<p><b>%s: </b> %s<br /><b>%s: </b> %s</p>" %
        [ _('Workaround'), Time.in_words(commitment.workaround * 1.day, true),
          _('Correction'), Time.in_words(commitment.correction * 1.day, true) ]
    else
      '-'
    end
  end

  @@help_on_status = nil
  # Show the '?' icon with the link on status explanation on the wiki
  # TODO : this implementation can be improved a LOT
  def help_on_status
    @@help_on_status ||= %Q{<a href="#{App::Help::RequestStatusUrl}"} <<
       ' target="_blank" class="aligned_picture" style="vertical-align: top;">' <<
      image_tag("icons/question_mark.gif") <<
    '</a>'
  end


  @@help_on_severity = nil
  # Show the '?' icon with the link on severity explanation on the wiki
  # TODO : this implementation can be improved a LOT
  def help_on_severity
    @@help_on_severity ||= %Q{<a href="#{App::Help::RequestSeverityUrl}"} <<
       ' target="_blank" class="aligned_picture" style="vertical-align: top;">' <<
      image_tag("icons/question_mark.gif") <<
      '</a>'
  end

  # Shows a popup with the description of a status for the request.
  # Ex: <%= link_to_box_on_status(@request_tosca) %>
  def link_to_box_on_status(request)
    return '' unless request
    options = { :popup => ['help_statut', 'height=300,width=600'] }
    link_to(request.statut.name, help_statut_path(request.statut_id), options)
  end

  NEW_WINDOW = { :target => '_blank' }
  # Link to the inline help to post a request
  def public_link_to_help_new_request
    public_link_to(_("Submission of a request"),
                   App::Help::NewRequestUrl, NEW_WINDOW)
  end

  # Link to the the inline help about life cycle of a demand
  def public_link_to_howto_request
    public_link_to(_("The life cycle of a request"),
                   App::Help::LifeCycleUrl, NEW_WINDOW)
  end

  # Link to the inline help about the differents states of a demand
  def public_link_to_help_request_status
    public_link_to(_("Help on the status"),
                   App::Help::RequestStatusUrl, NEW_WINDOW)
  end

  def public_link_to_status_legend
    public_link_to(_("Legend of statutes"), statuts_path, NEW_WINDOW)
  end

end
