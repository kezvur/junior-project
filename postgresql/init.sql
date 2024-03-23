CREATE DATABASE juniortodoo;

\c juniortodoo;

CREATE TABLE todo(
    todo_id SERIAL PRIMARY KEY,
    description VARCHAR(255)
);