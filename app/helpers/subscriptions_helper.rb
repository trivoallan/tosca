module SubscriptionsHelper

  def link_to_subscription(model, options = {})
    model_name = model.class.name
    if model.subscribed? session[:user]
      alert_success = _('You are now unsubscribed to this %s') % model_name
      alert_failure = _('You can not unsubscribe to this %s') % model_name
      url = send("ajax_unsubscribe_#{model_name.underscore}_url", model)
      icon = StaticImage::unsubscribe
      text = _('Unsubscribe to this %s') % model_name
      method = :delete
    else
      alert_success = _('You are now subscribed to this %s') % model_name
      alert_failure = _('You can not subscribe to this %s') % model_name
      url = send("ajax_subscribe_#{model_name.underscore}_url", model)
      icon = StaticImage::subscribe
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
    result << ' '
    result << link_to_remote(text, options)
  end

  def subscribers_list(model, options = {})
    subscribers = model.subscribers
    result = ''
    if options.has_key? :id
      result << "<ul id=\"#{options[:id]}\">"
    else
      result << '<ul>'
    end
    if subscribers.size == 0
      result << '<li>'
      result << _('There is no subscribers.')
      result << '</li>'
    else
      subscribers.each do |u|
        result << '<li>'
        result << link_to(u, account_path(u))
        result << '</li>'
      end
    end
    result << '</ul>'
  end

end
