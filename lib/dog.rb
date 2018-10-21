class Dog

  attr_accessor :name, :breed
  attr_reader :id

  # accepts key value pairs as arguments to initialize {name: 'sparky', breed: 'scottish terrier'}
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end #end initialize

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      name TEXT,
      breed TEXT,
      id INTEGER PRIMARY KEY
    )
    SQL

    DB[:conn].execute(sql)
  end #end .create_table

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  #saves an instance of the dog class and updates its @id then returns the instance.
  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end #end #save


  #this needs work I need to
  def self.create(name:, breed:)
    # binding.pry
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end #end .create

  # returns a new dog object by id
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    # need to pass hash key value pairs to instantiate.
    dog = Dog.new(name: row[1],breed: row[2],id: row[0])
    dog
  end #end .find_by_id


  #creates an instance of a dog if it does not already exist
  #two dogs have the same name and different breed, it returns the correct dog
  #creating a new dog with the same name as persisted dogs, it returns the correct dog
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)[0]

    #if not found the if clause begins  and we create a new dog that is saved. The new dog is returned
    if row == nil
      dog = Dog.new(name: name, breed: breed)
      dog.save
      return dog
    #if found we create a new instance from a database row.
    else
      return self.new_from_db(row)
    end
  end



  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
    # binding.pry
  end

  #updates the record associated with the given instance.
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end #end Dog class
