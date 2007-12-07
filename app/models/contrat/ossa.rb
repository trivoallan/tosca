class Contrat::Ossa < Contrat

  @@id = 0
  def self.id
    @@id
  end

  @@name = 'Ossa'
  def self.to_s
    @@name
  end
end
