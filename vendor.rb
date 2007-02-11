#!/usr/bin/ruby

# A appeler comme ceci :
# find . -name "*.rb" | grep -v "vendor" | xargs ./vendor.rb

copyright = [
  "#####################################################\n",
  "# Copyright Linagora SA 2006 - Tous droits réservés.#\n",
  "#####################################################\n" ]

$*.each do |arg|
  File.open(arg, File::RDWR) { |file|
    lines = file.readlines
    unless (lines[1] === copyright[1])
      file.rewind
      file.print copyright
      file.print lines
    end
  }
end
