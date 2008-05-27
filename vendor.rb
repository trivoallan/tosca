#!/usr/bin/env ruby

# A appeler comme ceci :
# find . -name "*.rb" | grep -v "vendor" | xargs ./vendor.rb

require '/usr/lib/ruby/1.8/fileutils'

copyright = [
  "#####################################################\n",
  "# Copyright Linagora SA 2006 - Tous droits réservés.#\n",
  "#####################################################\n" ]

tmp = "/tmp/tmp.rb"
$*.each do |arg|
  rename = false
  File.open(arg, File::RDWR) { |file|
    lines = file.readlines
    if (lines[1] === copyright[1])
      rename = true
      File.open(tmp, File::CREAT | File::RDWR) { |new|
        new.print lines[3..-1]
      }
    end
  }
  if rename
    File.delete(arg)
    FileUtils.mv tmp, arg
  end
end
