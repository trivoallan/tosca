#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module AccountHelper

  def avatar(recipient, engineer)
    if recipient
      logo_client(recipient.client)
    else
      if engineer.image_id.blank?
        StaticImage::logo_08000
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
      update(:with => "client_id", :url => 'ajax_place')
    observe_field "client_id", @@options
  end

  def observe_engineer_client_field
    @@contracts_options ||= PagesHelper::SPINNER_OPTIONS.dup.\
      update(:with => "client_id", :url => 'ajax_contracts')
    observe_field "engineer_client_id", @@contracts_options
  end

end
