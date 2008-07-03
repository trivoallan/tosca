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
      rawsources, rawpackages  = '', ''
      for component in components.split(' ')
        open(url+'/dists/'+distro+'/'+component+'/source/Sources.gz') do |file|
          gz = Zlib::GzipReader.new(file)
          rawsources << gz.read
          gz.close
        end
        open(url+'/dists/'+distro+'/'+component+'/binary-i386/Packages.gz') do |file|
          gz = Zlib::GzipReader.new(file)
          rawpackages << gz.read
          gz.close
        end
      end
    end

    i = 0
    sources = []
    rawsources.each_line do |line|
      field = line.split(': ', 2)[0]
      if ['Package', 'Binary'].include? field
        if field == 'Package'
          i += 1
          sources[i] = {}
        end
        sources[i][field] = line.split(': ', 2)[1].strip
      end
    end

    i = 0
    packages = []
    rawpackages.each_line do |line|
      field = line.split(': ', 2)[0]
      if ['Package', 'Version', 'Description'].include? field
        if field == 'Package'
          i += 1
          packages[i] = {}
        end
        packages[i][field] = line.split(': ', 2)[1].strip
      end
    end

    return { :sources => sources, :packages => packages }

  end

end
