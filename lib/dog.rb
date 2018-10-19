class Dog
   attr_accessor :id, :name, :breed
   def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end
   def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT
    )
    SQL
     DB[:conn].execute(sql)
  end
   def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
     DB[:conn].execute(sql)
  end
   def self.new_from_db(row)
    attributes = { id: row[0], name: row[1], breed: row[2] }
    Dog.new(attributes)
  end
   def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
       DB[:conn].execute(sql, self.name, self.breed)
       self.id = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
      self
    end
  end
   def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
     DB[:conn].execute(sql, self.name, self.breed,self.id)
  end

   def self.create(dog)
    self.new(dog).save
  end
   def self.find_by_id(id)
    sql= <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
     found = DB[:conn].execute(sql, id)[0]
    self.new_from_db(found)
  end
  
