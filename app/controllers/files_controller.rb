#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

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

  def index
    out = "Downloading file with id #{params[:id]} : #{params[:filename]}"
    render_text out
  end

  def download
    map = {:piecejointe => 'file', 
           :contribution => 'patch',
           :document => 'fichier',
           :binaire => 'archive' 
    }
    root = [ 'files', params[:file_type], map[:"#{params[:file_type]}"] ] * '/'
    fullpath = [ root, params[:id], params[:filename] ] * '/'
    send_file fullpath
  end

end
