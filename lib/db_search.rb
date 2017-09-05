require_relative 'db_connection'
require_relative 'basic_sql_action'
module Searchable

  def where(params)
    n = self.table_name
    val = params.values
    arr = params.keys.join(" = ? AND ")
    where_arr = arr + " = ?"
    res = DBConnection.execute(<<-SQL, *val)
    SELECT
      *
    from
      #{n}
    where
      #{where_arr}
    SQL
    self.parse_all(res)
  end
end

class SQLObject
  extend Searchable
end
