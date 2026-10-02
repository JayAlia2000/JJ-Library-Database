-- J&J's Library – Relational Schema
-- Based on the original 2023 ERD (Buildings, Rooms, Equipment, Sections, Staff,
-- Members, Books, Genres, Checkout), refined in 2026. MySQL 8.0.16+.
-- Refinements: Checkout gets its own primary key, Author becomes its own table
-- (many-to-many via book_authors), and "Late" is calculated instead of stored.

CREATE DATABASE IF NOT EXISTS library;
USE library;

CREATE TABLE staff (
    staff_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    job_title     VARCHAR(50),
    hire_date     DATE,
    address       VARCHAR(150),
    phone_number  VARCHAR(20),
    email         VARCHAR(100) UNIQUE
);

CREATE TABLE buildings (
    building_id      INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    address          VARCHAR(150),
    phone_number     VARCHAR(20),
    number_of_floors SMALLINT,
    year_built       SMALLINT,
    manager_staff_id INT,
    FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE rooms (
    room_id      INT AUTO_INCREMENT PRIMARY KEY,
    room_number  VARCHAR(10) NOT NULL,
    building_id  INT NOT NULL,
    UNIQUE (building_id, room_number),
    FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

CREATE TABLE equipment (
    equipment_id    INT AUTO_INCREMENT PRIMARY KEY,
    type            VARCHAR(50) NOT NULL,
    cost            DECIMAL(10,2) CHECK (cost >= 0),
    lifespan_years  SMALLINT,
    room_id         INT,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE sections (
    section_id  INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    staff_id    INT,
    room_id     INT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (room_id)  REFERENCES rooms(room_id)
);

CREATE TABLE genres (
    genre_id  INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE authors (
    author_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL
);

CREATE TABLE books (
    book_id           INT AUTO_INCREMENT PRIMARY KEY,
    isbn              VARCHAR(13) UNIQUE,
    title             VARCHAR(200) NOT NULL,
    publisher         VARCHAR(100),
    publication_date  DATE,
    cost              DECIMAL(8,2) CHECK (cost >= 0),
    quantity          INT NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    genre_id          INT,
    section_id        INT,
    FOREIGN KEY (genre_id)   REFERENCES genres(genre_id),
    FOREIGN KEY (section_id) REFERENCES sections(section_id)
);

CREATE TABLE book_authors (
    book_id    INT NOT NULL,
    author_id  INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id)     ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Members: the web app's sign-up form wrote to this (originally user_data)
CREATE TABLE members (
    member_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    address       VARCHAR(150),
    phone_number  VARCHAR(20),
    email         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE checkouts (
    checkout_id      INT AUTO_INCREMENT PRIMARY KEY,
    member_id        INT NOT NULL,
    book_id          INT NOT NULL,
    checkout_datetime DATETIME NOT NULL,
    due_date         DATE NOT NULL,
    return_date      DATE NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id),
    CHECK (due_date >= DATE(checkout_datetime))
);

-- Sample data
INSERT INTO staff (first_name, last_name, job_title, hire_date, email) VALUES
('Dana', 'Brooks', 'Branch Manager', '2019-03-01', 'dbrooks@jjlibrary.org'),
('Marcus', 'Hill', 'Librarian', '2021-08-15', 'mhill@jjlibrary.org');

INSERT INTO buildings (name, address, number_of_floors, year_built, manager_staff_id) VALUES
('Main Branch', '100 Main St', 2, 1998, 1);

INSERT INTO rooms (room_number, building_id) VALUES ('101', 1), ('102', 1), ('201', 1);

INSERT INTO equipment (type, cost, lifespan_years, room_id) VALUES
('Computer', 950.00, 5, 1), ('Printer', 400.00, 6, 1), ('Projector', 1200.00, 7, 3);

INSERT INTO sections (name, staff_id, room_id) VALUES
('Fiction', 2, 1), ('Nonfiction', 2, 2), ('Science Fiction', 2, 3);

INSERT INTO genres (name) VALUES ('Fiction'), ('Nonfiction'), ('Science Fiction');

INSERT INTO authors (first_name, last_name) VALUES
('Toni', 'Morrison'), ('Octavia', 'Butler'), ('James', 'Baldwin');

INSERT INTO books (isbn, title, publisher, cost, quantity, genre_id, section_id) VALUES
('9781400033416', 'Beloved', 'Vintage', 16.00, 2, 1, 1),
('9780446675505', 'Parable of the Sower', 'Grand Central', 17.00, 3, 3, 3),
('9780679744726', 'The Fire Next Time', 'Vintage', 14.00, 1, 2, 2);

INSERT INTO book_authors VALUES (1, 1), (2, 2), (3, 3);

INSERT INTO members (first_name, last_name, phone_number, email) VALUES
('James', 'Ryan', '555-010-1001', 'jryan@example.com'),
('Maya', 'Lewis', '555-010-1002', 'mlewis@example.com'),
('Andre', 'Grant', NULL, 'agrant@example.com');

INSERT INTO checkouts (member_id, book_id, checkout_datetime, due_date, return_date) VALUES
(1, 1, '2026-09-01 10:00', '2026-09-15', '2026-09-18'),
(2, 2, '2026-09-10 14:30', '2026-09-24', NULL),
(3, 2, '2026-09-20 11:15', '2026-10-04', NULL),
(1, 3, '2026-09-05 16:45', '2026-09-19', NULL);
