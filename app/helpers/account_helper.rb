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
module AccountHelper

  def avatar(recipient, engineer)
    if recipient
      logo_client(recipient.client)
    else
      if engineer.image_id.blank?
        StaticImage::logo_service
      else
        image_tag(url_for_file_column(engineer.image, 'image', 'thumb'))
      end
    end
  end

  def get_title(user)
    result = ''
    if session[:user].id == @user.id
      result << _('My account')
    else
      result << _('Account of %s') % @user.name
    end
    result << " (#{_('User|Inactive')})" if @user.inactive
    result
  end

  def observe_client_field
    @@options ||= PagesHelper::SPINNER_OPTIONS.dup.\
      update(:with => "client", :url => 'ajax_place')
    observe_field("user_client_true", @@options) <<
      observe_field("user_client_false", @@options)
  end

  def observe_client_list
    @@contracts_options ||= PagesHelper::SPINNER_OPTIONS.dup.\
      update(:with => "client_id", :url => 'ajax_contracts')
    observe_field "user_recipient_client_id", @@contracts_options
  end

  def form_become(user)
    recipient = user.recipient
    result = ''
    if @ingenieur && recipient && !user.inactive?
      result << %Q{<form action="#{become_account_path(recipient)}" method="post">}
      result << %Q{<input name="commit" value='#{_('Become')}' type="submit" /></form>}
    end
    result
  end

end
