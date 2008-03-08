class LoadArchs < ActiveRecord::Migration
  class Arch < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Arches
    return unless Arch.count == 0

    # Binary packages known architectures
    %w(noarch all ppc sparc32 sparc64 i386 i586 i686 x86_64).each { |a|
      Arch.create(:nom => a)
    }
  end

  def self.down
    Arch.destroy_all
  end
end
