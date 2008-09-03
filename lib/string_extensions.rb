module StringExtensions
  def symbolize
    self.gsub(/[^A-Za-z0-9]+/, "_").gsub(/(^_+|_+$)/, "").underscore.to_sym
  end

  def titlecase
    self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
  end

  def to_name(last_part = '')
    self.underscore.gsub('/', ' ').humanize.titlecase.gsub(/\s*#{last_part}$/, '')
  end

  # this convenience method search an url in a string and add the "http://" needed
  # RFC sur les URLS : link:"http://rfc.net/rfc1738.html"
  # Made from this regexp : link:"http://www.editeurjavascript.com/scripts/scripts_formulaires_3_250.php"
  #
  # It works with :
  #  "www.google.com"
  #  "http://www.google.com"
  #  "toto tutu djdjdjd google.com" >
  #  "toto tutu djdjdjd http://truc.machin.com/touo/sdqsd?tutu=1&machin google.com/toto/ddk?tr=1&machin"
  #TODO: A améliorer
  def urlize
    (self.gsub(/(\s+|^)[a-zA-Z]([\w-]{0,61}\w)?\.[a-zA-Z]([\w-]{0,61}\w)?(\.[a-zA-Z]([\w-]{0,61}\w)?)?/) { |s| " http://" + s.strip }).strip
  end

  # Small convenience method which replace each space by its unbreakable html
  # equivalent.
  #
  # Call it like this :
  #   "this is a test".unbreak
  #     this&nbsp;is&nbsp;a&nbsp;test"
  def unbreak
    self.gsub(' ', '&nbsp;')
  end

end

String.send :include, StringExtensions
