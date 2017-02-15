require 'pry'

class Dog

  attr_reader :id
  attr_accessor :name, :breed

  def initialize(id: nil, name: , breed: )
    @id=id
    @name=name
    @breed=breed
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql=<<-SQL
      INSERT INTO dogs
      (name, breed) VALUES
      (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id= DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create (hash)
    new_dog=self.new(hash )
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql= <<-SQL
      SELECT * from dogs
      WHERE id=?
    SQL
    results=DB[:conn].execute(sql, id).flatten
    new_dog=self.new(id: results[0], name: results[1], breed: results[2])
  end

  def self.find_or_create_by(hash)
    sql=<<-SQL
      SELECT * from dogs
      WHERE name=? AND breed=?
    SQL
    results=DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    if results.empty?
      Dog.create(hash)
    else
      self.find_by_id(results[0])
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE name=?
    SQL
    results=DB[:conn].execute(sql, name).flatten
    self.new_from_db(results)
  end

  def update
    sql=<<-SQL
      UPDATE dogs SET
      name=?, breed=? WHERE id= ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
