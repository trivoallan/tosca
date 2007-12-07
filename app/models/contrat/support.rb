class Contrat::Support < Contrat

  @@id = 1
  def self.id
    @@id
  end

  @@name = 'Support'
  def self.to_s
    @@name
  end
end
