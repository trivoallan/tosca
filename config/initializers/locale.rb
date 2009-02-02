# Tell the I18n library where to find your translations
I18n.load_path += Dir[ File.join(RAILS_ROOT, 'locales', '*.{rb,yml}') ]

# Tell the supported locales. This is the one of additional setting by Ruby-Locale for Ruby on Rails.
# If supported_locales is not set, the locale information which is given by WWW browser is used.
# This setting is required if your application wants to restrict the locales.
I18n.supported_locales = Dir[ File.join(RAILS_ROOT, 'locales', '*.{rb,yml}') ].collect{|v| File.basename(v, ".*")}.uniq

# Tell the default locale. If this value is not set, "en" is set.
# With this library, this value is used as the lowest priority locale
# (If other locale candidates are not found, this value is used).
# I18n.default_locale = "en-US"
