require_relative 'db_connection'
require 'active_support/inflector'

class DataLive
  def self.columns
    name = self.table_name
    if @columns == nil
      res = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{name}
      SQL
      @columns = res[0].map {|el| el.to_sym}
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end
      define_method("#{col}=") {|x| self.attributes[col] = x}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = self.to_s.downcase + 's'
  end

  def self.all
    name = self.table_name
    res = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{name}
    SQL
    self.parse_all(res)
  end

  def self.parse_all(results)
    results.map {|el| self.new(el)}
  end

  def self.find(id)
    self.all.each { |obj| return obj if obj.id == id }
    nil
  end

  def initialize(params = {})
    params.each do |k, v|
      raise "unknown attribute '#{k}'" unless self.class.send(:columns).include?(k.to_sym)
      self.send("#{k}=", v)
    end
  end

  def attributes
    if @attributes == nil
      @attributes = {}
    end
      @attributes
  end

  def attribute_values
    self.class.send(:columns).map {|k| self.send("#{k}")}
  end

  def insert
    col = self.class.send(:columns)
    col_names = col[1..-1].map {|el| el.to_s}.join(",")
    res = []
    (self.class.send(:columns).length - 1).times {res << "?"}
    question_marks = res.join(", ")
    value = self.attribute_values[1..-1]
    n = self.class.send(:table_name)
    DBConnection.execute(<<-SQL,*value)
    INSERT INTO
      #{n} (#{col_names})
    values
      (#{question_marks})
    SQL
    self.send("#{col.first}=", DBConnection.last_insert_row_id)
  end

  def update
    col = self.class.send(:columns)
    col_names = col[1..-1].map {|el| el.to_s}.join("= ?,")
    col_names += "= ?"
    value = self.attribute_values
    value << value.shift
    n = self.class.send(:table_name)
    DBConnection.execute(<<-SQL,*value)
    update
      #{n}
    set
      #{col_names}
    where
      id = ?
    SQL
  end

  def save
    if self.send(:id)
      self.update
    else
      self.insert
    end
  end
end
