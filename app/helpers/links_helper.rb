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

# This helpers is here to put links helper not really
# related to any model or controller.
#
# They help to generate link with image, for instance,
# or link to files.
#
# It contains also general links in the header/footer part
#
# require 'mime/types'

module LinksHelper

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
        show = StaticImage::patch
      else
        show = filename
      end
      url = url_for_file_column(record, file, :absolute => true)
      if public
        public_link_to show, url
      else
        link_to show, url
      end
    end
  end

  def public_link_to_file(record, file, options={})
    link_to_file(record, file, options, true)
  end

  #Call it like link_to_file
  # TODO : This method clearly needs more work.
  def link_to_file_redbox(record, method)
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
                     :background_close => true)
      #Text
      elsif mime_type =~ /^text\// && defined?(UvHelper)
        link_to_uv(record, filename)
      else
        '-' + mime_type
      end
    end
  end

  #Print a redbox div for a piecejointe
  #Call it like : redbox_div("script/../config/../files/piecejointe/file/4/image.png", "toto")
  #Only one option : background_close. If true you can click on the background of the div to close it
  def redbox_div(relative_path, content, options = {})
    return '' if relative_path.blank? or content.nil?
    content << '<div style="position: absolute;top: 0;right: 0;">'
    content << link_to_close_redbox(StaticImage::hide_notice) << '</div>'
    content = link_to_close_redbox(content) if options.has_key? :background_close
    return  <<EOS
      <div id="#{relative_path}" style="display: none;">
        #{content}
      </div>
      #{link_to_redbox(StaticImage::view, relative_path)}
EOS
  end

  @@delete_options = { :class => 'nobackground', :method => :delete }
  def delete_options(objet_name)
    @@delete_options.update(:confirm =>
        _('Do you really want to delete %s') % objet_name)
  end

  ### Header ###
  # TODO : put all those methods into another module
  # and merge it dynamically in this module
  def public_link_to_home
    public_link_to(_('Home'), welcome_path)
  end

  def link_to_issues
    link_to(_('Issues'), issues_path, :title =>
            _('Consult issues'))
  end

  def link_to_all_issues
    link_to(_('All issues'), issues_path, :title =>
            _('Consult all issues'))
  end

  def link_to_tobd_issues
    link_to(_('Pending Issues'), pending_issues_path, :title =>
            _('Consult issues which are waiting an action from you'))
  end

  def public_link_to_softwares
    public_link_to(_('Softwares'), softwares_path, :title =>
                   _('Access to the list of software'))
  end

  def public_link_to_contributions
    public_link_to(_('Contributions'), contributions_path,
                   :title => _('Access to the list of contributions.'))
  end

  def public_link_to_about()
    public_link_to('?', about_welcome_path,
                   :title => _("About %s") % App::Name)
  end

  def public_link_to_forgotten_pwd
    public_link_to(_('Forgotten password ?'), forgotten_password_accounts_path)
  end

  # No cache for this one. It's not a public link /!\
  def link_to_admin
    link_to(_('Administration'), admin_welcome_path,
            :title => _('Administration interface'))
  end


  def public_link_to_remote_theme
    link_to_remote_redbox(StaticImage.icon_css, :url => theme_welcome_path,
                          :method => :get, :update => 'theme_box')
  end

end
