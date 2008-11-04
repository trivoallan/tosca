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
module AlertsHelper
 
  MP3_FLASH_PLAYER = "dewplayer-mini.swf"
  MP3_FOLDER_URL = "mp3"
  
  def play_mp3(filename)
    mp3 = "../../#{MP3_FOLDER_URL}/#{filename}"
    options = "&amp;autostart=1&amp;autoreplay=1&amp;bgcolor=FFFFFF"
    param = "#{mp3_folder_path}?mp3=#{mp3}#{options}"
    "<object type=\"application/x-shockwave-flash\" 
      data=\"#{param}\" width=\"1\" height=\"1\">
     <param name=\"movie\" value=\"#{param}\"/></object>"
  end
 
  def mp3_folder_path
    "../../#{MP3_FOLDER_URL}/#{MP3_FLASH_PLAYER}"
  end
  
end
