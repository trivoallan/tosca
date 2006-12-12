#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

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


def avg(data)
  return 0 unless data.is_a? Array
  data.inject(0){|n, value| n + value} / data.size.to_f
end
