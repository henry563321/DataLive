# DataLive - Object Relational Mapping in Rails

DataLive connects tables in the database with the class, you can call these class
'model'. Class connect with each other with the function called associations.

DataLive put a great focus on name conventions. We recommended you to use the
name of class or columns dealing with the association between tables, although
these mappings can be defined explicitly.

Here's some feature of the of the library:

### basic function

The library can do basic database manipulate like
`table_name.all,
table_name.find(id),
new_attribute.insert,
attribute.update`

### search and association

Also the library provide the function of search with the specific attribute,
and make association between classes

![association](/association.png)

## Run the example demo

1. `git clone https://github.com/henry563321/DataLive`
2. `bundle install`
3. open `pry`
4. `load 'sample/sample.rb'`
5. you are all set! play around with Human, Food, Restaurant.
