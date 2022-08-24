class Dog
    attr_accessor :name, :breed, :id

    #readable and writable attributes initialized with key argument values
    def initialize(name:, breed:, id: nil)
      @id = id
      @name = name
      @breed = breed
    end

    #define class and execute correct SQL
    def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
      end

      #method drops dogs table from the db
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    # save inserts a new record in the db and returns instance
    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    #create a new row in db and return new instance of the Dog class
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    #introducing the constructors that extend .new functionality without overwriting initialize
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    #return array of Dog instances
    def self.all
        sql = <<-SQL
          SELECT *
          FROM dogs
        SQL
    
        DB[:conn].execute(sql).map do |row|
          self.new_from_db(row)
        end
      end

    #find Dog instance matching the name from db
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.name = ?
            LIMIT 1;
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    #return object found by id
    def self.find(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.id = ?
            LIMIT 1;
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

end
