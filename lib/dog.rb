class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_by_name_and_breed(name, breed)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL
    row = DB[:conn].execute(sql, name, breed)[0]
    Dog.new_from_db(row) if row
  end

  def self.find_or_create_by(name:, breed:)
    if Dog.find_by_name_and_breed(name, breed)
      Dog.find_by_name_and_breed(name, breed)
    else
      Dog.create(name, breed)
    end
  end
end
