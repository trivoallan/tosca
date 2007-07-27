ActiveRecord::Schema.define(:version => 1) do

  create_table :beers, :force => true do |t|
    t.column :name,       :string
    t.column :rating,        :integer
  end
  
  create_table :glasses, :force => true do |t|
    t.column :name, :string
  end

  create_table :drunkards, :force => true do |t|
    t.column :name, :string
  end

  create_table :beers_drunkards, :id => false, :force => true do |t|
    t.column :beer_id, :integer
    t.column :drunkard_id, :integer
  end
  
end
