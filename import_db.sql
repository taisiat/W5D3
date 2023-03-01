PRAGMA foreign_keys = ON;
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(300),
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- id   question   user 
-- 1    oop        tk
-- 2    sql        tk
-- 3    oop        ahmed
-- 4    sql        darren

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- id(reply)  body                              question        parent_reply   author   
-- 1          "yeah it mean obkeect orient"     id(of qest)      null           darren
-- 2          "no that's wrong, it is whatever" id(of qest)      1              taylor
-- 3          "thanks"                          id(of qest)      2              tk

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    users (fname, lname)
VALUES 
    ('Ahmed', 'R'), 
    ('Taisia', 'K');

INSERT INTO 
    questions (title, body, user_id)
VALUES 
    ('OOP', 'What is OOP?', 2);

INSERT INTO 
    question_follows (question_id, user_id)
VALUES 
    (1, 2);

INSERT INTO 
    replies (body, question_id, parent_reply_id, author_id)
VALUES 
    ('OOP is Obje,, Or,, Pro,,', 1, null, 1);

INSERT INTO 
    question_likes (question_id, user_id)
VALUES 
    (1, 2);

    