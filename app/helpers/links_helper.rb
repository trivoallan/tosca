#
# This helpers is here to put links helper not really
# related to any model or controller.
#
# They help to generate link with image, for instance,
# or link to files.
#
# It contains also general links in the header/footer part
#
require 'mime/types'

module LinksHelper

  # this contains the hash for escaping hover effect for images
  # this is put in every links with image
  NO_HOVER = { :class => 'no_hover' }

  ALIGNED_PICTURE = { :class => 'aligned_picture' }

  # Call it like this : link_to_file(document, 'file')
  # don't forget to update his public alter ego just below
  # DO NOT EVER CALL this method with 'public' parameter set
  # to true, use <b>public_link_to_file</b> instead
  #
  def link_to_file(record, file, options={}, public = false)
    return '-' unless record
    filepath = record.send(file)
    unless filepath.blank? or not File.exist?(filepath)
      filename = filepath[/[._ \-a-zA-Z0-9]*$/]
      if options.has_key? :image
        show = StaticImage::patch and html_options = NO_HOVER
      else
        show = filename and html_options = {}
      end
      url = url_for_file_column(record, file, :absolute => true)
      if public
        public_link_to show, url, html_options
      else
        link_to show, url, html_options
      end
    end
  end

  def public_link_to_file(record, file, options={})
    link_to_file(record, file, options, true)
  end

  #Call it like link_to_file
  # TODO : This method clearly needs more work.
  def link_to_file_redbox(record, method, options={}, public = false)
    return '-' unless record

    file_exec = record.file_options[:file_exec]
    return '-' unless file_exec

    method = method.to_sym if method.is_a? String

    filepath = record.send(method)
    filename = filepath[/[._ \-a-zA-Z0-9]*$/]
    unless filepath.blank? or not File.exist?(filepath)
      mime_type = record.file_mime_type
      #To be XHTML compliant
      relative_path = "#{method}_" <<
        record.send("#{method}_relative_path").tr!("/", "_")
      #Image
      if mime_type =~ /^image\//
        redbox_div(relative_path,
                   image_tag(url_for_image_column(record, method, :fit_size)),
                     NO_HOVER.dup.update(:background_close => true))
      #Text
      elsif mime_type =~ /^text\//
        link_to(StaticImage::view, uv_piecejointe_path(record),
                NO_HOVER.dup.update(:popup =>
                  [filename, 'height=600,width=800,scrollbars=yes']))
      else
        '-'
      end
    end
  end

  #Print a redbox div for a piecejointe
  #Call it like : redbox_div("script/../config/../files/piecejointe/file/4/image.png", "toto")
  #Only one option : background_close. If true you can click on the background of the div to close it
  def redbox_div(relative_path, content, options = {})
    return '' if relative_path.blank? or content.nil?
    content << '<div style="position: absolute;top: 0;right: 0;">'
    content << link_to_close_redbox(StaticImage::hide_notice, NO_HOVER) << '</div>'
    content = link_to_close_redbox(content) if options.has_key? :background_close
    return  <<EOS
      <div id="#{relative_path}" style="display: none;">
        #{content}
      </div>
      #{link_to_redbox(StaticImage::view, relative_path, :class => 'no_hover')}
EOS
  end

  @@delete_options = { :class => 'nobackground', :method => :delete }
  def delete_options(objet_name)
    @@delete_options.update(:confirm =>
        _('Do you really want to delete %s') % objet_name)
  end

  # This short helper allows to make an image link
  # It's different from the text link coz' the dynamic background is removed
  # Call it like this :
  #   <%= link_to_no_hover image_create(_('new url')), path %>
  def link_to_no_hover(*args)
    args << LinksHelper::NO_HOVER
    link_to *args
  end

  ### Header ###
  # TODO : put all those methods into another module
  # and merge it dynamically in this module
  def public_link_to_home
    public_link_to(_('Home'), bienvenue_path)
  end

  def link_to_requests
    link_to(_('Requests'), demandes_path, :title =>
            _('Consult requests'))
  end

  def link_to_all_requests
    link_to(_('All the requests'), demandes_path, :title =>
            _('Consult all the requests'))
  end

  def link_to_tobd_requests
    link_to(_('Pending Requests'), pending_demandes_path, :title =>
            _('Consult requests which are waiting an action from you'))
  end

  def public_link_to_softwares
    public_link_to(_('Software'), logiciels_path, :title =>
                   _('Access to the list of software'))
  end

  def public_link_to_contributions
    public_link_to(_('Contributions'), contributions_path,
                   :title => _('Access to the list of contributions.'))
  end

  # About page
  def public_link_to_about()
    public_link_to('?', about_bienvenue_path,
                   :title => _("About %s") % App::Name)
  end

  # No cache for this one. It's not a public link /!\
  def link_to_admin
    link_to(_('Administration'), admin_bienvenue_path,
            :title => _('Administration interface'))
  end


  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(account_id, title=_('My&nbsp;account'))
    return '' unless account_id
    link_to title, account_path(account_id)
  end
end
