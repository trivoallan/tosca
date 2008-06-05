
#For html2text
require 'cgi'

# Meta data ici :
# ajouter par Lstm
module App

  # application
  Name = "TOSCA"
  Version = "0.7.2"
  Copyright = " ©2006-2008 Linagora SA".gsub(' ','&nbsp;')
  FilesPath = File.join RAILS_ROOT, 'files'

  # service
  ServiceName = "OSSA"
  ServiceFullName = "Open Source Software Assurance".gsub(' ','&nbsp;')
  CompanyName = "Linagora"
  CompanySite = "http://www.linagora.com"
  CompanySitePath = "/ossa"

  # contacts
  PhonePrefix = "08000"
  PhoneCode = "54689"
  PhoneText = "LINUX"

  InternetAddress = "08000linux.com"

  ContactPhone = "08000 54689"
  ContactMail = "team@08000linux.com"

end

# Converts the date value of a calendar into a Time object
# Value is expected to be a string in the form : "YYYY-MM-DD"
#
# Call it like this :
#   calendar2time('2007-05-21')
#   => Mon May 21 00:00:00 +0200 2007
def calendar2time(value)
  values = value.split('-')
  Time.mktime(values[0], values[1], values[2], 0, 0, 0)
end


# Remove entirely a tree. Like 'rm -Rf directory'
def rmtree(directory)
  Dir.foreach(directory) do |entry|
    next if entry =~ /^\.\.?$/     # Ignore . and .. as usual
    path = directory + "/" + entry
    if FileTest.directory?(path)
      rmtree(path)
    else
      File.delete(path)
    end
  end

  Dir.delete(directory)
end

# compute the average of an Array
def avg(data)
  return 0 unless data.is_a? Array
  data.inject(0){|n, value| n + value} / data.size.to_f
end


#Found here
#http://blog.yanime.org/articles/2005/10/10/html2text-function-in-ruby
#TODO : Faire la numérotation pour les listes numérotée
def html2text(html)
  text = html.
    gsub(/(&nbsp;)+/im, ' ').squeeze(' ').strip.gsub("\n",'').gsub(/(&lsquo;)+/, "'").
    gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

  links = []
  linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>([^>]*)<[^>]*>/i
  while linkregex.match(text)
    links << $~[3]
    text.sub!(linkregex, "#{$~[4]}[#{links.size}]")
  end

  text = CGI.unescapeHTML(
    text.
      gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
      gsub(/<!--.*-->/m, '').
      gsub(/<hr(| *[^>]*)>/i, "----------------------------\n").
      gsub(/<li(| [^>]*)>/i, "\n * ").
      gsub(/<blockquote(| [^>]*)>/i, '> ').
      gsub(/<br(| *[^>]*)>/i, "\n").
      gsub(/<\/(h[\d]+|p)(| [^>]*)>/i, "\n\n").
      gsub(/<\/address(| [^>]*)>/i, "\n").
      gsub(/<\/pre(| [^>]*)>/i, "\n").
      gsub(/<\/?(b|strong)[^>]*>/i, "*").
      gsub(/<\/?(i|em)[^>]*>/i, "/").
      gsub(/<\/?u[^>]*>/i, "").
      gsub(/<[^>]*>/, '')
  )
  for i in (0...links.size).to_a
    text = text + "\n  [#{i+1}] <#{CGI.unescapeHTML(links[i])}>" unless links[i].nil?
  end

  text
end

#This method clean a string from
def cleanize(text)

end


module Utils
  # Used to help a newcomer
  def self.check_files(path, error_msg)
    if !File.exists? path
      $stderr.puts error_msg
      $stderr.puts "You have to specify one, you'll find an example in #{path}.sample."
      $stderr.puts "You have to copy it to #{path} and adapt it to your configuration."
      $stderr.puts "cp #{path}.sample #{path}"
      exit(-1)
    end
  end

end
