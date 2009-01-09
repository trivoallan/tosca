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
#!/usr/bin/ruby

=begin rdoc
   Ruby Refactor script
   Takes one or more ruby source files as argument, and change a term in an other.
   The term must be in minus case
   Made by Michel Loiseleur <mloiseleur@linagora.com>
=end

require 'getoptlong'

class Refactor

   NAME="Refactor"
   VERSION="0.1"

   def initialize(options)
      
      opt_parser = GetoptLong.new
      opt_parser.set_options(
        ['--from', '-f',             GetoptLong::REQUIRED_ARGUMENT],
        ['--to', '-t',               GetoptLong::REQUIRED_ARGUMENT],
        ['--help', '-h', '-?',       GetoptLong::NO_ARGUMENT],
        ['--version', '-v',          GetoptLong::NO_ARGUMENT])

      begin
         opt_parser.each do |opt, arg|
            case opt
               when '--from' then 
              @from=Regexp.new(arg.to_s)
              @from_capitalized=Regexp.new(arg.to_s.capitalize)
               when '--to'   then @to=arg.to_s
               when '--help'     then self.help
               when '--version'  then self.version
            end
         end
      rescue
         self.help
      end
      @filenames=options
   end

   def parse_all
      @filenames.each {|file| self.parse(file) }
   end

   ##
   # This method parses the code, and outputs the indented version
   #
   def parse(file)
     ind=0
     final_version=Array.new

     puts "Parsing #{file}.."
     if file==nil or not File.file?(file)
       $stderr.puts "Error: file '#{file}' not found"
       self.help
     end
     openfile=File.readlines(file)
     begin
       openfile.each do |line|

         line[@from] = @to if line[@from]
         line[@from_capitalized] = @to.capitalize if line[@from_capitalized]
         
         final_version << line
       end
     end

     out_file=File.open(file, "w")
     out_file.puts final_version
   end

   ##
   # Prints a help text and exits the program
   #
   def help
      STDERR.puts <<-FIN
  Usage: refactor [options] SOURCEFILE
    Specific options:
      -f, --from                       Specifie the input pattern, in lower case
      -t, --to                         Specifies the output pattern, in lower case too

    Common options:
      -h, -?, --help                       Show this message
      -v, --version                    Show version information
   FIN
      exit 0
   end
   ##
   # Prints the version and exits
   #
   def version
      STDERR.puts <<-FIN
   #{NAME} #{VERSION}
 Released under the GPL by Diego Cano
 http://www.blep.org/
   FIN
      exit 0
   end
end

##
# Creates a refactor and launch the parsing
#
Refactor.new(ARGV).parse_all
