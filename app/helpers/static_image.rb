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

require 'static'

# This helpers is here to put in cache most of images
# urls generation. The images do not moves after the
# web server is launched, so there are computed only the
# first time one needs it and saved in class variables.
#
# You need to restart server in order to reinitialize them
# but you don't need to recompute them each time you want
# to display a picture.
#
# All images follow this scheme :
#   @@view = nil
#   def self.view
#     @@view ||= tag('icons/b_view.png', options('Consulter', '15x15'))
#   end
class StaticImage < Static::ActionView

  #########################################################

  # To have globals options
  def self.options(desc = '', size = nil)
    options = { :alt => desc, :title => desc, :class => 'aligned_picture' }
    options[:size] = size if size
    options
  end

  @@view = nil
  def self.view
    desc = _("View")
    @@view ||= image_tag('icons/zoom.png', options(desc, '16x16'))
  end

  @@edit = nil
  def self.edit
    desc = _("Update")
    @@edit ||= image_tag('icons/pencil.png', options(desc, '16x16'))
  end

  # You should prefer to use
  # image_create(message) : with message being a good tooltip for the link
  @@new = nil
  def self.new
    desc = _("New")
    @@new ||= image_tag('icons/add.png', options(desc, '16x16'))
  end

  @@delete = nil
  def self.delete
    desc = _("Delete")
    @@delete ||= image_tag('icons/cancel.png', options(desc, '16x16'))
  end

  @@hide_notice = nil
  def self.hide_notice
    desc = _("Hide")
    @@hide_notice ||= image_tag('icons/cancel.png', options(desc, '16x16'))
  end

  @@help= nil
  def self.help
    desc = _("Help")
    @@help ||= image_tag('icons/help.png', options(desc, '16x16'))
  end

  # Navigation
  @@back = nil
  def self.back
    desc = _("Back")
    @@back ||= image_tag("icons/arrow_undo.png", options(desc, '16x16'))
  end

  @@first_page = nil
  def self.first_page
    desc = _("First page")
    @@first_page ||= image_tag("icons/resultset_first.png", options(desc, '16x16'))
  end

  @@previous_page = nil
  def self.previous_page
    desc = _("Previous page")
    @@previous_page ||= image_tag("icons/resultset_previous.png", options(desc, '16x16'))
  end

  @@next_page = nil
  def self.next_page
    desc = _("Next page")
    @@next_page ||= image_tag("icons/resultset_next.png", options(desc, '16x16'))
  end

  @@last_page = nil
  def self.last_page
    desc = _("Last page")
    @@last_page ||= image_tag("icons/resultset_last.png", options(desc, '16x16'))
  end

  @@folder = nil
  def self.folder
    desc = _("File")
    @@folder ||= image_tag('icons/folder.png', options(desc, '16x16'))
  end

  @@patch = nil
  def self.patch
    desc = _("Contribution")
    @@patch ||= image_tag('icons/page_code.png', options(desc, '16x16'))
  end

  # Security
  @@public = nil
  def self.public
    desc = _("Make public")
    @@public ||= image_tag('icons/lock_open.png', options(desc, '16x16'))
  end

  @@private = nil
  def self.private
    desc = _("Make private")
    @@private ||= image_tag('icons/lock.png', options(desc, '16x16'))
  end

  # Logos
  @@logo_service = nil
  def self.logo_service
    @@logo_service ||= image_tag(App::ServiceImage, options(App::ContactPhone))
  end

  @@logo_service_small = nil
  def self.logo_service_small
    @@logo_service_small ||= image_tag(App::ServiceImageSmall, options(App::ContactPhone))
  end

  @@tosca = nil
  def self.tosca
    desc = _("Home page")
    @@tosca ||= image_tag('logo_tosca.gif', options(desc))
  end

  @@ruby = nil
  def self.ruby
    desc = _("Tosca on Rails")
    @@ruby ||= image_tag('icons/ruby.png', options(desc, '15x15'))
  end

  @@linagora = nil
  def self.linagora
    desc = _("Tosca on Rails")
    @@linagora ||= image_tag('logo_linagora.gif', options(desc, '176x44'))
  end

  @@favimage_png = nil
  def self.favimage_png
    @@favimage_png ||= image_path("icons/favicon.png")
  end

  @@favimage_ico = nil
  def self.favimage_ico
    @@favimage_ico ||= image_path("icons/favicon.ico")
  end

  @@print = nil
  def self.print
    desc = _("Print")
    @@print ||= image_tag('icons/printer.png', options(desc, '16x16'))
  end

  # type mime icons
  @@mime_txt = nil
  def self.mime_txt
    @@mime_txt ||= image_tag('icons/mime-type/txt.png')
  end

  @@mime_pdf = nil
  def self.mime_pdf
    @@mime_pdf ||= image_tag('icons/mime-type/pdf.png')
  end

  @@mime_ods = nil
  def self.mime_ods
    @@mime_ods ||= image_tag('icons/mime-type/ods.png')
  end

  @@mime_csv = nil
  def self.mime_csv
    @@mime_csv ||= image_tag('icons/mime-type/csv.png')
  end

  # Other
  @@spinner = nil
  def self.spinner
    @@spinner ||= image_tag('spinner.gif', :id => 'spinner',
                            :style=> 'display: none;')
  end
  
  @@icon_tag = nil
  def self.icon_tag
    desc = _("Manage tags")
    @@icon_tag ||= image_tag('icons/tag_red.gif', options(desc, '16x16'))
  end

  @@expand = nil
  def self.expand
    @@expand ||= image_tag('icons/navigation_expand.gif', options('expand'))
  end

  @@hide = nil
  def self.hide
    @@hide ||= image_tag('icons/navigation_hide.gif', options('hide'))
  end

  @@checkbox = nil
  def self.checkbox
    @@checkbox ||= image_tag 'icons/checkbox.gif', options('Checkbox', '13x13')
  end

  @@sla_ok = nil
  def self.sla_ok
    @@sla_ok ||= image_tag 'icons/accept.png', options('Time achieved', '16x16')
  end

  @@sla_running = nil
  def self.sla_running
    @@sla_running ||= image_tag 'icons/time.png', options('Time is running', '16x16')
  end

  @@sla_exceeded = nil
  def self.sla_exceeded
    @@sla_exceeded ||= image_tag 'icons/exclamation.png', options('Time exceeded', '16x16')
  end
  
  @@comments = nil
  def self.comments
    @@comments ||= image_tag('icons/comments.png', options('Comments', '16x16'))
  end
  
  @@documents = nil
  def self.documents
    @@documents ||= image_tag('icons/page_copy.png', options('Attachments', '16x16'))
  end
  
  @@telephone = nil
  def self.telephone
    @@telephone ||= image_tag('icons/telephone.png', options('Phonecalls', '16x16'))
  end
  
  @@description = nil
  def self.description
    @@description ||= image_tag('icons/book_open.png', options('Description', '16x16'))
  end
  
  @@history = nil
  def self.history
    @@history ||= image_tag('icons/film.png', options('History', '16x16'))
  end
  
  
  ##############################################
  # Severity
  # Display an icon matching severity
  # They are stored in an array in order to cover all of 'em
  @@images_severite = Array.new(Severite.count)
  def self.severite(d)
    result = @@images_severite[d.severite_id]
    if result.nil?
      desc = (d.respond_to?(:severites_name) ? d.severites_name : d.severite.name)
      file_name = "severite_#{d.severite_id}.gif"
      @@images_severite[d.severite_id] = image_tag(file_name, :title => desc, 
        :alt => desc, :class => 'aligned_picture')
      result = @@images_severite[d.severite_id]
    end
    result
  end


end
