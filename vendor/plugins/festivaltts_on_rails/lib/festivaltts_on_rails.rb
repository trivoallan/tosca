# FestivalttsOnRails
require 'digest/sha1'
require "#{File.dirname(__FILE__)}/festival4r.rb"

MP3_FLASH_PLAYER_URL = "dewplayer-mini.swf"
MP3_FOLDER_URL = "/festivaltts_mp3"
MP3_FOLDER_PATH = "#{RAILS_ROOT}/public" + MP3_FOLDER_URL

# Generates the mp3 file and the javascript utility that shows the
# voice player.
def text_to_flash_player(text)
  filename =  Digest::SHA1.hexdigest("--tosca--#{Locale.get.language}--#{text}--tosca--") + ".mp3"
  text.to_mp3(MP3_FOLDER_PATH + "/" + filename) unless File.exists?(MP3_FOLDER_PATH + "/" + filename)
  html_for_mp3_flash(MP3_FOLDER_URL + "/" + filename)
end

# Returns needed html for playing mp3.
def html_for_mp3_flash(filename, width = 0, height = 0)
 "<object type=\"application/x-shockwave-flash\"\n \
   data=\"#{compute_public_path(MP3_FLASH_PLAYER_URL, "flash")}?mp3=#{compute_public_path(filename, "festivaltts_mp3")}&amp;autostart=1&amp;autoreplay=1\" width=\"#{width}\"\n \
   height=\"#{height}\">\n \
   <param name=\"movie\" value=\"#{compute_public_path(MP3_FLASH_PLAYER_URL, "flash")}?mp3=#{compute_public_path(filename, "festivaltts_mp3")}&amp;autostart=1&amp;autoreplay=1\" />\n \
   </object>"
end
