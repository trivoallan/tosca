class Contrat::Ossa < Contrat


  @@id = 0
  def self.id
    @@id
  end

  @@name = 'ossa'
  def self.to_s
    @@name
  end
end
