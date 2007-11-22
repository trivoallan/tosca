class Hash
  # Will convert the given hash to a querystring. It uses the PHP/Rails
  # convention of foo[bar]=baz&foo[boo]=doo to mean:
  #
  #    foo = {'bar' => 'baz', 'boo' => 'doo'}
  #
  # Also it support nested hashes and if the inner-most value is an array
  # it supports the foo[bar][]=a&foo[bar][]=b syntax to mean:
  #
  #    foo = {'bar' => ['a', 'b']}
  #
  # Much effort was made to ensure that we duck-typed everything so as long
  # as your objects behaved like hashes and arrays it would work. The following
  # basic rules must be followed:
  #
  # * A hash-like structure should respond to :each but not :to_str and :to_ary
  # * Array-like structures should respond to :to_ary
  #
  # By default the querystring is html escaped (& turned into &amp;) since this
  # will be most often used in a link_to helper but you can pass false for
  # the initial value to disable this behavior
  #
  #--
  # This file was incorporated from my filtered_list plugin. It really should
  # be located somewhere else and used by both but it is so small I hate to
  # make a plugin for just a utility function.
  #++
  def to_qs(escape=true, prefix='')
    inject(Array.new) do |memo, pair|
      key, value = pair

      key = CGI::escape key.to_s
      key = prefix == '' ? key : "#{prefix}[#{key}]"

      if value.respond_to? :to_ary
        value.each {|v| memo << "#{key}[]=#{CGI::escape v.to_s}" }
      elsif value.respond_to?(:each) && !value.respond_to?(:to_str)
        memo << value.to_qs(escape, key)
      else
        memo << "#{key}=#{CGI::escape value}" unless value.nil?
      end
      memo
    end.sort * (escape ? '&amp;' : '&')
    # Sort not necessary for production use but make testing reliable
  end
end