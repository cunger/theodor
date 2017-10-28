CREATE TABLE todo_lists (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE todo_items (
  id serial PRIMARY KEY,
  name text NOT NULL,
  todo_list_id integer NOT NULL REFERENCES todo_lists (id) ON DELETE CASCADE,
  done boolean NOT NULL DEFAULT false
);
