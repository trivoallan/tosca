# Repository Module for Tosca
# Written by Adrien Cunin - June/July 2008 - Linagora

require 'open-uri'
require 'zlib'

module Repository

  def list_packages(list)

    for repository in list
      splitted = repository.split(' ', 4)
      url = splitted[1]
      distro = splitted[2]
      components = splitted[3]
      rawpackages  = ''
      for component in components.split(' ')
        pkg_url = url+'/dists/'+distro+'/'+component+'/binary-i386/Packages.gz'
        begin
          open(pkg_url) do |file|
            gz = Zlib::GzipReader.new(file)
            rawpackages << gz.read
            gz.close
          end
        rescue Exception => e
          puts "Failed to open #{pkg_url} : #{e}"
        end
      end
    end

    i = 0
    packages = []
    rawpackages.each_line do |line|
      field = line.split(': ', 2)[0]
      if %w(Package Version Description).include? field
        if field == 'Package'
          i += 1
          packages[i] = {}
        end
        packages[i][field] = line.split(': ', 2)[1].strip
      end
    end
    packages 
  end

end
