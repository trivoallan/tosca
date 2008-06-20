#
# Ruby Interface to festival tts system
#
# Requires festivaltts and lame.
# Must be run in a UNIX environment.

class String

  # Creates a file with name "filename" and with the generated with festival tts, the string itself and lame.
  # Can handle one parameter:
  # We have change it to espeak, since it's REALLY better in this area
  def to_mp3(filename)
    system("espeak -v #{Locale.get.language} \"#{self}\" -s125 --stdout | lame --resample 44 - > #{filename} 2> /dev/null")
  end

end
