#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

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
module StaticImage

  include Static

  # TODO : utiliser options (cf delete pour exemple)
  # We cannot cache a parametered image

  #########################################################

  # por éviter la réaffection de desc à chaque coup
  def self.options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  @@view = nil
  def self.view
    desc = _("View")
    @@view ||= ActionView::image_tag('icons/b_view.png', options(desc, '15x15'))
  end

  @@edit = nil
  def self.edit
    desc = _("Update")
    @@edit ||= ActionView::image_tag('edit_icon.gif', options(desc, '15x15'))
  end

  @@delete = nil
  def self.delete
    desc = _("Delete")
    @@delete ||= ActionView::image_tag('delete_icon.gif', options(desc, '15x17'))
  end

  @@hide_notice = nil
  def self.hide_notice
    desc = _("Hide")
    @@hide_notice ||= ActionView::image_tag('delete_icon.gif', options(desc, '15x17'))
  end

  @@help= nil
  def self.help
    desc = _("Help")
    @@help ||= ActionView::image_tag('icons/b_help.png', options(desc, '15x15'))
  end

  # Navigation

  @@home = nil
  def self.home
    desc = _("Home page")
    @@home ||= ActionView::image_tag("home.gif", options(desc, '17x18'))
  end

  @@back = nil
  def self.back
    desc = _("Back")
    @@back ||= ActionView::image_tag("back3.gif", options(desc, '15x15'))
  end

  @@first_page = nil
  def self.first_page
    desc = _("First page")
    @@first_page ||= ActionView::image_tag("first_page.png", options(desc, '14x14'))
  end

  @@previous_page = nil
  def self.previous_page
    desc = _("Previous page")
    @@previous_page ||= ActionView::image_tag("previous_page.png", options(desc, '14x14'))
  end

  @@next_page = nil
  def self.next_page
    desc = _("Next page")
    @@next_page ||= ActionView::image_tag("next_page.png", options(desc, '14x14'))
  end

  @@last_page = nil
  def self.last_page
    desc = _("Last page")
    @@last_page ||= ActionView::image_tag("last_page.png", options(desc, '14x14'))
  end

  @@folder = nil
  def self.folder
    desc = _("File")
    @@folder ||= ActionView::image_tag('folder_icon.gif', options(desc, '16x16'))
  end

  @@patch = nil
  def self.patch
    desc = _("Contribution")
    @@patch ||= ActionView::image_tag('patch.gif', options(desc, '16x16'))
  end

  # Security
  @@public = nil
  def self.public
    desc = _("Make public")
    @@public ||= ActionView::image_tag('public_icon.png', options(desc, '17x16'))
  end

  @@private = nil
  def self.private
    desc = _("Make private")
    @@private ||= ActionView::image_tag('private_icon.png', options(desc, '12x14'))
  end

  # Logos
  @@logo_08000 = nil
  def self.logo_08000
    @@logo_08000 ||= ActionView::image_tag('logo_08000.gif', options('08000 LINUX'))
  end

  @@lstm = nil
  def self.lstm
    desc = _("Home page")
    @@lstm ||= ActionView::image_tag('logo_lstm.gif', options(desc))
  end

  @@ruby = nil
  def self.ruby
    desc = _("OSSA on rails")
    @@ruby ||= ActionView::image_tag('ruby.png', options(desc, '15x15'))
  end

  @@linagora = nil
  def self.linagora
    desc = _("OSSA on rails")
    @@linagora ||= ActionView::image_tag('logo_linagora.gif', options(desc, '176x44'))
  end

  @@favimage_png = nil
  def self.favimage_png
    @@favimage_png ||= ActionView::image_path("favicon.png")
  end

  @@favimage_ico = nil
  def self.favimage_ico
    @@favimage_ico ||= ActionView::image_path("favicon.ico")
  end

  @@print = nil
  def self.print
    desc = _("Print")
    @@print ||= ActionView::image_tag('imprimer.png', options(desc, '22x22'))
  end

  # type mime icons
  @@mime_txt = nil
  def self.mime_txt
    @@mime_txt ||= ActionView::image_tag('icons/mime-type/txt.png')
  end

  @@mime_pdf = nil
  def self.mime_pdf
    @@mime_pdf ||= ActionView::image_tag('icons/mime-type/pdf.png')
  end

  @@mime_ods = nil
  def self.mime_ods
    @@mime_ods ||= ActionView::image_tag('icons/mime-type/ods.png')
  end

  @@mime_csv = nil
  def self.mime_csv
    @@mime_csv ||= ActionView::image_tag('icons/mime-type/csv.png')
  end

  # Other
  @@spinner = nil
  def self.spinner
    @@spinner ||= ActionView::image_tag('spinner.gif', :id => 'spinner',
                            :style=> 'display: none;')
  end

  @@expand = nil
  def self.expand
    @@expand ||= ActionView::image_tag('navigation_expand.gif', options('expand'))
  end

  @@hide = nil
  def self.hide
    @@hide ||= ActionView::image_tag('navigation_hide.gif', options('hide'))
  end

  ##############################################
  # Severity

  # Display an icon matching severity
  # They are stored in an array in order to cover all of 'em
  @@images_severite = Array.new(Severite.count)
  def self.severite(d)
    result = @@images_severite[d.severite_id]
    if result.nil?
      desc = (d.respond_to?(:severites_nom) ? d.severites_nom : d.severite.nom)
      file_name = "severite_#{d.severite_id}.gif"
      @@images_severite[d.severite_id] = ActionView::image_tag(file_name, :title =>
                                                   desc, :alt => desc)
      result = @@images_severite[d.severite_id]
    end
    result
  end


end


