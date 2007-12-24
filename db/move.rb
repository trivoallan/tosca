Start = 31
Deviation = 1

Dir.foreach('migrate/') do |m|
  if m =~ /^\d+_.*\.rb$/
    file = m.split(/_/, 2)
    idx = file.first.to_i
    if idx > Start
      puts "mv #{m} #{idx + Deviation}_#{file.last}"
      File.rename("migrate/#{m}", "0#{idx + Deviation}_#{file.last}")
    end
  end
end
