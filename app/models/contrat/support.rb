class Contrat::Support < Contrat


  @@id = 1
  def self.id
    @@id
  end

  @@name = 'support'
  def self.to_s
    @@name
  end
end
