class Dog 
  
  attr_accessor :id, :name, :breed
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255), 
        breed VARCHAR(255)
      )
      SQL
      
      DB[:conn].execute(sql)
  end 
  
  def self.drop_table
     DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end 
  
  def self.create(name: name, breed: breed)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end 
  
  def self.find_by_id(id)
  sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    
    DB[:conn].execute(sql, id).map {  |row| self.new_from_db(row) }.first
  end 
  
  def self.find_or_create_by(name:, breed:)
    question = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    unless question.empty?
      info = question[0]
      new_dog = Dog.new(id: info[0], name: info[1], breed: info[2])
    else 
      new_dog = self.create(name: name, breed: breed)
    end 
    new_dog
  end 
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    
    DB[:conn].execute(sql, name).map {  |row| self.new_from_db(row) }.first
  end 
  
  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end 

  def save
    if self.id
      self.update 
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end 
    self
  end 
  
  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
end 