class Dog

  attr_accessor :name, :breed, :id

  ALL = []

  def initialize(props = {})
    props.each {|key, value| self.send(("#{key}="), value)}
    ALL << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(props)
    new_dog = Dog.new(props)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * From dogs
      WHERE id = ?
    SQL
    db_dog = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new_from_db(db_dog)
  end

  def self.new_from_db(row)
    attr_hash = {name: row[1], breed: row[2], id: row[0]}
    dog = Dog.new(attr_hash)
    dog
  end

  def self.find_by_name(dog)
    sql = <<-SQL
      SELECT * From dogs
      WHERE name = ?
    SQL
    db_dog = DB[:conn].execute(sql, dog)[0][1]
    found_dog = ALL.find {|dog| dog.name == db_dog}
    found_dog.id = DB[:conn].execute(sql, dog)[0][0]
    found_dog
  end

  #where did the hashes go
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    db_dog = DB[:conn].execute(sql, name, breed)[0]
    if db_dog != nil
      new_dog = Dog.new_from_db(db_dog)
    else
      dog = Dog.create(name: name, breed: breed)
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
