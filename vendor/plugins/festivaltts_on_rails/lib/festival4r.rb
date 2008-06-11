#
# Ruby Interface to festival tts system
#
# Requires festivaltts and lame.
# Must be run in a UNIX environment.

class String

  # Creates a file with name "filename" and with the generated with festival tts, the string itself and lame.
  # Can handle one parameter:
  def to_mp3(filename)
    system("echo \"#{self}\" | text2wave | lame --resample 44 - > #{filename} 2> /dev/null")
  end

end
