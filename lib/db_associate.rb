require_relative 'db_search'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.camelcase,
      primary_key: :id,
      foreign_key: (name.to_s + "_id").to_sym
    }
    options = defaults.merge(options)

    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id,
      foreign_key: (self_class_name.downcase.to_s + "_id").to_sym
    }
    options = defaults.merge(options)

    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options

    define_method(name) do
      tar_class = options.model_class
      key = self.send(:attributes)[options.foreign_key.to_sym]

      res = tar_class.where( { options.primary_key => key } )
      return nil if res == []
      res.first
    end
  end

  def has_many(name, options = {})
    self_class_name = self.to_s
    options = HasManyOptions.new(name, self_class_name, options)

    define_method(name) do
      tar_class = options.model_class
      key = self.send(:attributes)[options.primary_key.to_sym]
      res = tar_class.where({options.foreign_key => key})
      res
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key

      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      foreign_key_val = self.send(through_foreign_key)
      res = DBConnection.execute(<<-SQL, foreign_key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL

      source_options.model_class.parse_all(res).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class DataLive
  extend Associatable
end
