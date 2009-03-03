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
# UPLOAD > file_column.rb:l.596
#  :root_path => File.join(RAILS_ROOT, "files"),

# ROUTES > routes.rb
#  routing files to prevent download from public access

# MOVE FILES TO PROTECT > script shell
#  mv public/folders_to_protect files/

# DOCUMENTATION
#  http://wiki.rubyonrails.com/rails/pages/HowtoSendFiles
#  http://robertrevans.com/article/files-outside-public-directory
#  http://svn.techno-weenie.net/projects/plugins/acts_as_attachment/

class FilesController < ApplicationController

  before_filter :login_required, :except => [:download]

  # TODO : review and shorten this method. Camelize should to the job.
  def download
    file_type = params[:file_type].intern

    # mapping path
    map = {:attachment => 'file',
           :contribution => 'patch',
           :archive => 'file' }

    # TODO : get model name without hash
    model = { :attachment => Attachment,
              :contribution => Contribution,
              :archive => Archive }

    # Login needed for anything but contribution
    return if (file_type != :contribution && login_required == false)

    # building path
    root = [ App::FilesPath, params[:file_type], map[file_type] ] * '/'

    # TODO : FIXME
    # the dirty gsub hack on ' ' is needded, because urls with '+' are weirdly reinterpreted.
    fullpath = [ root, params[:id], params[:filename].gsub(' ','+') ] * '/'

    # Attachment has to be restricted.
    scope_active = (@session_user.recipient? and file_type == :attachment)

    # Ensure that we can remove scope
    begin
      Attachment.set_scope(@session_user.contract_ids) if scope_active
      # Check if one have the right to find it : ie to download it,
      # Using scope model of Tosca
      model[file_type].find(params[:id])
    ensure
      Attachment.remove_scope if scope_active
    end
    send_file fullpath

  rescue
    # if error on finding target
    flash.now[:warn] = _("This file does not exist.")
    redirect_to_home
  end

end
