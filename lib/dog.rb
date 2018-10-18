class Dog
  include ORM::InstanceMethods
  extend ORM::ClassMethods

  ATTRIBUTES = {
    id: "INTEGER PRIMARY KEY",
    name: "TEXT",
    breed: "BREED"
  }

  ATTRIBUTES.keys.each {|key|
    attr_accessor key
  }

  def self.attributes
    ATTRIBUTES
  end

  def self.find_by_name(name)
    self.find_by_attributes(name: name)
  end
end
