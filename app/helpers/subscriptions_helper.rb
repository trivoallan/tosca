#
# Copyright (c) 2006-2009 Linagora
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
module SubscriptionsHelper

  def link_to_subscription(model, options = {})
    model_name = model.class.name
    if model.subscribed? @session_user
      alert_success = _('You are now unsubscribed to this %s') % model_name
      alert_failure = _('You can not unsubscribe to this %s') % model_name
      url = send("ajax_unsubscribe_#{model_name.underscore}_url", model)
      icon = StaticPicture::unsubscribe
      text = _('Unsubscribe to this %s') % model_name
      method = :delete
    else
      alert_success = _('You are now subscribed to this %s') % model_name
      alert_failure = _('You can not subscribe to this %s') % model_name
      url = send("ajax_subscribe_#{model_name.underscore}_url", model)
      icon = StaticPicture::subscribe
      text = _('Subscribe to this %s') % model_name
      method = :post
    end

    options.reverse_merge!(:url => url,
      :method => method,
      :before => "Element.show('spinner')",
      :success => "alert('#{alert_success}')",
      :failure => "alert('#{alert_failure}')",
      :complete => "Element.hide('spinner')")
    result = link_to_remote(icon, options)
    result << " #{link_to_remote(text, options)}"
  end

  def subscribers_list(model, options = {})
    subscribers = model.subscribers
    result, options_id = '', options[:id]
    unless options.has_key?(:no_ul)
      if options_id
        result << %Q{<ul id="#{options_id}">}
      else
        result << '<ul>'
      end
    end
    if subscribers.empty?
      result << "<li>#{_('There is no subscribers.')}</li>"
    else
      subscribers.each{|u| result << "<li>#{link_to(u, account_path(u))}</li>"}
    end
    result << '</ul>' unless options.has_key?(:no_ul)
  end

end
