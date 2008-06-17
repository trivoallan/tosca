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
    recipient = user.beneficiaire
    result = ''
    if @ingenieur && recipient && !user.inactive?
      result << %Q{<form action="#{become_account_path(recipient)}" method="post">}
      result << %Q{<input name="commit" value='#{_('Become')}' type="submit" /></form>}
    end
    result
  end

end
