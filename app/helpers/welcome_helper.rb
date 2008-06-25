module WelcomeHelper

  def html_wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1<br />")
  end

  # List of actions with Icons. They have to be declared in StaticImage::
  Icons = {
    :destroy => :delete,
    :edit => :edit,
    [:index,:list,:show] => :view,
    :new => [:new]
  }

  # It's not a constant, since the label of the links are
  # translated. So it's called once a time per page.
  def init_builder
    # List of special actions. It can be regexps
    @@texts = {
      'admin' => [_('has an administration interface')],
      'print' => _('has a pretty print page'),
      'suggestions'=> [_('allows to post suggestions')],
      'about'=> [_('displays informations')],
      'become'=> _('allows to become an other one'),
      'login'=> [_('allows to log in in the application')],
      'plan'=> [_('display this map')],
      'comment'=> _('allows to comment'),
      'deroulement'=> _('prints the life cycle of a request'),
      [/ajax/, /auto_complete/] => _('is ajaxified'),
      /_ods/ => _('allows to export datas in ODS')
    }
  end

  def build_bloc(elt, texts, icons)
    controller = elt.first
    elt.last.each do |action|
      next unless session[:user].authorized? "#{controller}/#{action}"
      options = { :controller => controller, :action => action }
      ### Texts ###
      @@texts.each { |i| case action; when *(i.first)
          value = i.last
          texts.push((value.is_a?(Array) ? link_to(value.first, options) : value))
        end
      }
      ### Icons ###
      Icons.each { |i| case action.intern; when *(i.first)
          if i.last.is_a? Array
            icons.push link_to(StaticImage.send(i.last.first), options)
          else
            icons.push StaticImage.send(i.last)
          end
        end
      }
    end
    icons.uniq!
    texts.uniq!
  end


end
