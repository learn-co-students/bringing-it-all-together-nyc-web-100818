module ORM
  module InstanceMethods

    def initialize(args)
      args.each{|key,value|
        self.send("#{key}=", value)
      }
    end

    def attribute_names_without_id
      self.class.attributes.keys[1..-1] # excluding id
    end

    def attribute_values_without_id
      attribute_names_without_id.collect{|column_name| self.send(column_name)}
    end

    def save
      self.persisted? ? update : insert
      self
    end

    def persisted?
      !!self.id
    end

    def insert
      columns = attribute_names_without_id.join(",")
      question_marks = attribute_names_without_id.count.times.collect{"?"}.join(",")
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{columns})
        VALUES (#{question_marks})
      SQL
      DB[:conn].execute(sql, *attribute_values_without_id)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
    end

    def update
      update_lines = attribute_names_without_id.collect{|column_name| "#{column_name} = ?"}.join(", ")
      sql = <<-SQL
        UPDATE #{self.class.table_name}
        SET #{update_lines}
        WHERE id = ?
      SQL
      DB[:conn].execute(sql, *attribute_values_without_id, self.id)
    end
  end

  module ClassMethods

    def new_from_db(row)
      args = {}
      self.attributes.keys.each_with_index do |column_name, index|
        args[column_name] = row[index]
      end
      self.new(args)
    end

    def find_or_create_by(args)
      self.find_by_attributes(args) || self.create(args)
    end

    def find_by_attributes(args)
      conditions = args.keys.collect{|key| "#{key.to_s} = ?"}.join(" AND ")
      sql = <<-SQL
        SELECT * FROM #{self.table_name} WHERE #{conditions} LIMIT 1;
      SQL
      DB[:conn].execute(sql, *args.values).map{|row|
        self.new_from_db(row)
      }.first
    end

    def find_by_id(id)
      self.find_by_attributes(id: id)
    end

    def create(args)
      new_instance = self.new(args)
      new_instance.save
    end

    def table_name
      "#{self.to_s.downcase}s"
    end

    def create_table
      column_def = self.attributes.collect{|column_name,column_type|
        "#{column_name} #{column_type}"
      }
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS #{self.table_name} (
          #{column_def.join(", ")}
        );
      SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS #{self.table_name};
      SQL
      DB[:conn].execute(sql)
    end
  end
end
