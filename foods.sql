CREATE TABLE foods (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  restaurant_id INTEGER,

  FOREIGN KEY(restaurant_id) REFERENCES restaurants(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE restaurants (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES humans(id)
);

INSERT INTO
  humans (id, name)
VALUES
  (1, "bolei"), (2, "henry");

INSERT INTO
  restaurants (id, address, owner_id)
VALUES
  (1, "MANHATTAN", 1),
  (2, "BROOKLYN", 1),
  (3, "QUEEN", 2),
  (4, "BRONX", 2);

INSERT INTO
  foods (id, name, restaurant_id)
VALUES
  (1, "Pizza", 1),
  (2, "Sandwich", 2),
  (3, "Bread", 3),
  (4, "Chip", 2),
  (5, "Chicken", 4);
