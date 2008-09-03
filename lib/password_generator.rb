module PasswordGenerator

  @@mkpasswd = nil
  def generate_password
    @@mkpasswd ||= File.exist?('/usr/bin/mkpasswd')
    generated = ''
    # mkpasswd bug with control characters
    # so, we hash the string to resolve this problem
    seed = "--#{rand(10000)}--#{Time.now}--#{self.login}--".hash.to_s
    if @@mkpasswd
      generated = %x[#{"echo '#{seed}' | /usr/bin/mkpasswd -s"}]
      generated.chomp!
    else
      generated = Digest::SHA1.hexdigest(seed)[0,10]
    end
    self.pwd, self.pwd_confirmation = Array.new(2, generated)
  end

end
