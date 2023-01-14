CREATE TABLE users (
  id serial PRIMARY KEY,
  username text NOT NULL UNIQUE,
  password text NOT NULL,
  session_id text
);

CREATE TABLE products (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE,
  unit text NOT NULL
);

CREATE TABLE items (
  id serial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity numeric NOT NULL CHECK(quantity >= 0),
  best_before date NOT NULL,
  status text NOT NULL DEFAULT 'in stock'
);

INSERT INTO products (name, unit)
VALUES ('Eggs', 'Dozen'),
('Apple', 'Piece'),
('Cherries', 'Pound'),
('Milk', 'Liter'),
('Coca-cola', 'Can');

INSERT INTO items (product_id, quantity, best_before)
VALUES (1, 2, '2022-08-30'),
(1, 1, '2022-06-30'),
(1, 1, '2022-05-30'),
(1, 1, '2022-06-30'),
(1, 1, '2022-07-30'),
(1, 1, '2022-08-30'),
(1, 1, '2022-09-30'),
(2, 12, '2022-10-30'),
(1, 1, '2022-11-30'),
(1, 1, '2022-06-01'),
(1, 1, '2022-07-23'),
(3, 1, '2022-07-16'),
(4, 1, '2022-07-19'),
(1, 1, '2022-08-30'),
(1, 1, '2023-06-30'),
(5, 1, '2024-06-30'),
(1, 1, '2023-01-30'),
(1, 1, '2023-02-28'),
(5, 11, '2023-03-30'),
(3, 2, '2023-04-30'),
(4, 1, '2023-05-30'),
(4, 1, '2023-06-30'),
(3, 1, '2023-07-30'),
(1, 2, '2022-07-26'),
(2, 1, '2022-07-27'),
(5, 1, '2022-07-28'),
(4, 1, '2022-07-29'),
(3, 1, '2022-07-30');