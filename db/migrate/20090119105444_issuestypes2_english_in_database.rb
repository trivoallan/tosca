class Issuestypes2EnglishInDatabase < ActiveRecord::Migration
  def self.up
    associate = {
      "Information" => "Information",
      "Anomalie" => "Incident",
      "Évolution" => "Evolution",
      "Intervention" => "Call-out",
      "Étude" => "Analysis",
      "Livraison" => "Delivery",
    }

    Issuetype.all.each do |i|
      i.update_attribute(:name, associate[i.name]) if associate.has_key? i.name
    end
    Issuetype.new(:name => "Documentation")
  end

  def self.down
    id = 1
    %w(Information Anomalie Évolution Monitorat
       Intervention Étude Livraison).each{ |tr|
      td = Issuetype.new(:nom => tr); td.id = id; td.save
      id = id + 1
    }
  end
end
