classes = [ User, Contract, Demande ]
classes.each{|c| c.record_timestamps = false }
User.find(:all).each {|u| u.update_attribute :email, App::MaintenerEmail }
Contract.find(:all).each {|c| c.update_attribute :mailinglist, App::MaintenerEmail }
Demande.find(:all).each {|d| d.update_attribute :mail_cc, nil }
classes.each{|c| c.record_timestamps = true }
p "emails erased"
