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
=begin
 This modules encapsulates all tools for extracting files from
 source & binary packages, in those format
 <ul>
   <li>deb</li>
   <li>tar</li>
   <li>tgz|tar.gz</li>
   <li>tbz2|tar.bz2</li>
 </ul>
=end
module Extract

  # Extensions are automatically added, thanks to ruby
  # See Extract.files_from for the code
  @@extensions = []

=begin
    Returns an array of pair [ filename, filesize ]
    We do not need it to be an integer, for now.
    Call it like this : Extract::files_from("/tmp/toto.tar.gz")
=end
  def self.files_from(path)
    self.constants.each{ |c|
      @@extensions << [ self.module_eval("#{c}::Extensions"), self.module_eval(c.to_s) ]
    } if @@extensions.empty?


    @@extensions.each { |exts| 
      exts.first.each { |e|
        return exts.last.files_from(path) if path =~ e 
      } 
    }
  end


  # Extraction module for tgz, tar.gz, tbz2 & tar.bz2
  module Tar
    Extensions = [ /.tar.bz2$/i, /.tbz2$/i, /.tar.gz$/i, /.tgz$/i, /.tar$/i]

    # see Extract::file_from(path)
    def self.files_from(path)
      tar_cmd = 'tar tvf'
      tar_cmd = 'tar tvjf' if path =~ /bz2$/i
      tar_cmd = 'tar tvzf' if path =~ /gz$/i

      basename = ::Extract.remove_extension(path, Extensions)
      tar_cmd << " '#{path}'"
      result = []
      %x[#{tar_cmd}].split("\n").collect do |e|
        infos = e.split(" ")
        infos.last.sub!(basename, '') # remove basename from path
        result << [ infos.last, infos[2].to_i ] # [ filename, filesize ]
      end
      result
    end
  end

  # Extraction module for shitty deb packages
  module Deb
    Extensions = [ /.deb/i ]

    # see Extract::file_from(path)
    def self.files_from(path)
      deb_cmd = 'dpkg-deb --contents '

      basename = ::Extract.remove_extension(path, Extensions)
      deb_cmd << " '#{path}'"
      result = []
      %x[#{deb_cmd}].split("\n").collect { |e| e.split(/\s/) }.each { 
          |e| e.delete_if { |e| e == "" }}.collect { |infos| 
          infos[-1] = infos[5..-1].join(' ')
          infos.last.sub!('./', '/') # remove first dot
          result << [ infos.last, infos[2].to_i ] # [ filename, filesize ]
      }
      result
    end
  end

  protected
  def self.remove_extension(path, extensions)
    basename = File.basename(path)
    extensions.each { |e|
      basename = basename[0..-e.source.length] if basename =~ e
    }
    basename
  end

end


