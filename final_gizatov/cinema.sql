-- ============================================================
-- Final Project — Cinema Management System
-- Database: cinema_db / Schema: cinema
-- ============================================================

-- ============================================================
-- DATABASE + SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS cinema;

-- ============================================================
-- PART 2: CREATE TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS cinema.cinemas (
    cinema_id SERIAL PRIMARY KEY,
    cinema_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cinema.halls (
    hall_id SERIAL PRIMARY KEY,
    cinema_id INT NOT NULL REFERENCES cinema.cinemas(cinema_id) ON DELETE CASCADE,
    hall_name VARCHAR(50) NOT NULL,

    -- seat capacity cannot be negative
    seat_capacity INT CHECK (seat_capacity >= 0)
);

CREATE TABLE IF NOT EXISTS cinema.employees (
    employee_id SERIAL PRIMARY KEY,
    cinema_id INT NOT NULL REFERENCES cinema.cinemas(cinema_id) ON DELETE CASCADE,

    -- employee full name is required
    full_name VARCHAR(150) NOT NULL,

    position VARCHAR(50) NOT NULL,

    -- salary cannot be negative
    salary NUMERIC(10,2) CHECK (salary >= 0)
);

CREATE TABLE IF NOT EXISTS cinema.movies (
    movie_id SERIAL PRIMARY KEY,

    -- movie title must be unique
    title VARCHAR(150) UNIQUE,

    -- movie duration must be positive
    duration_minutes INT CHECK (duration_minutes > 0),

    release_date DATE NOT NULL,

    -- ticket price cannot be negative
    ticket_price NUMERIC(10,2) CHECK (ticket_price >= 0)
);

CREATE TABLE IF NOT EXISTS cinema.genres (
    genre_id SERIAL PRIMARY KEY,

    -- genre names must be unique
    genre_name VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS cinema.movie_genres (
    movie_genre_id SERIAL PRIMARY KEY,

    movie_id INT NOT NULL
    REFERENCES cinema.movies(movie_id)
    ON DELETE CASCADE,

    genre_id INT NOT NULL
    REFERENCES cinema.genres(genre_id)
    ON DELETE CASCADE,

    UNIQUE(movie_id, genre_id)
);

CREATE TABLE IF NOT EXISTS cinema.screenings (
    screening_id SERIAL PRIMARY KEY,

    movie_id INT NOT NULL
    REFERENCES cinema.movies(movie_id)
    ON DELETE CASCADE,

    hall_id INT NOT NULL
    REFERENCES cinema.halls(hall_id)
    ON DELETE CASCADE,

    -- screening dates must be after 2026
    screening_time TIMESTAMP CHECK (
        screening_time >= DATE '2026-01-01'
    )
);

CREATE TABLE IF NOT EXISTS cinema.customers (
    customer_id SERIAL PRIMARY KEY,

    -- customer name is required
    full_name VARCHAR(150) NOT NULL,

    -- customer email must be unique
    email VARCHAR(120) UNIQUE,

    -- gender restricted to valid values
    gender VARCHAR(10) CHECK (
        gender IN ('M', 'F', 'Other')
    ),

    loyalty_status VARCHAR(20) DEFAULT 'regular'
);

CREATE TABLE IF NOT EXISTS cinema.bookings (
    booking_id SERIAL PRIMARY KEY,

    customer_id INT NOT NULL
    REFERENCES cinema.customers(customer_id)
    ON DELETE RESTRICT,

    screening_id INT NOT NULL
    REFERENCES cinema.screenings(screening_id)
    ON DELETE CASCADE,

    booking_status VARCHAR(20) DEFAULT 'pending',

    total_amount NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS cinema.tickets (
    ticket_id SERIAL PRIMARY KEY,

    booking_id INT NOT NULL
    REFERENCES cinema.bookings(booking_id)
    ON DELETE CASCADE,

    -- seat count cannot be negative
    seat_count INT CHECK (seat_count > 0),

    -- price cannot be negative
    price_per_seat NUMERIC(10,2) CHECK (price_per_seat >= 0),

    total_price NUMERIC(10,2)
    GENERATED ALWAYS AS (
        seat_count * price_per_seat
    ) STORED
);

-- ============================================================
-- PART 3: ALTER TABLE
-- ============================================================

-- add phone number column for customers
ALTER TABLE cinema.customers
ADD COLUMN IF NOT EXISTS phone_number VARCHAR(15);

-- increase phone number length
ALTER TABLE cinema.customers
ALTER COLUMN phone_number TYPE VARCHAR(20);

-- rename hall_name for better readability
ALTER TABLE cinema.halls
RENAME COLUMN hall_name TO hall_title;

-- bookings should default to pending
ALTER TABLE cinema.bookings
ALTER COLUMN booking_status SET DEFAULT 'pending';

-- add employee position validation
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employee_position'
    ) THEN
        ALTER TABLE cinema.employees
        ADD CONSTRAINT chk_employee_position
        CHECK (
            position IN (
                'Manager',
                'Cashier',
                'Cleaner',
                'Technician'
            )
        );
    END IF;
END $$;

-- ============================================================
-- PART 4: INSERT
-- ============================================================

TRUNCATE TABLE cinema.tickets,
               cinema.bookings,
               cinema.movie_genres,
               cinema.screenings,
               cinema.employees,
               cinema.halls,
               cinema.movies,
               cinema.genres,
               cinema.customers,
               cinema.cinemas
RESTART IDENTITY CASCADE;

INSERT INTO cinema.cinemas (
    cinema_name,
    city
)
VALUES
('Mega Cinema', 'Almaty'),
('Star Cinema', 'Astana'),
('Atyrau Cinema', 'Atyrau');

INSERT INTO cinema.halls (
    cinema_id,
    hall_title,
    seat_capacity
)
VALUES
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Mega Cinema'),
    'Hall A',
    120
),
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Star Cinema'),
    'Hall B',
    90
),
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Atyrau Cinema'),
    'Hall C',
    150
);

INSERT INTO cinema.employees (
    cinema_id,
    full_name,
    position,
    salary
)
VALUES
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Mega Cinema'),
    'Aruzhan Saparova',
    'Manager',
    450000
),
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Star Cinema'),
    'Dias Nurgaliyev',
    'Cashier',
    250000
),
(
    (SELECT cinema_id
     FROM cinema.cinemas
     WHERE cinema_name = 'Atyrau Cinema'),
    'Madina Kenzhe',
    'Cleaner',
    180000
);

INSERT INTO cinema.movies (
    title,
    duration_minutes,
    release_date,
    ticket_price
)
VALUES
('Interstellar', 169, DATE '2026-02-11', 4500),
('Dune Part Two', 166, DATE '2026-03-15', 5000),
('Avatar Fire and Ash', 185, DATE '2026-05-20', 5500);

INSERT INTO cinema.genres (
    genre_name
)
VALUES
('Sci-Fi'),
('Drama'),
('Adventure');

INSERT INTO cinema.movie_genres (
    movie_id,
    genre_id
)
SELECT
    m.movie_id,
    g.genre_id
FROM (
    VALUES
    ('Interstellar', 'Sci-Fi'),
    ('Dune Part Two', 'Adventure'),
    ('Avatar Fire and Ash', 'Drama')
) AS x(movie_title, genre_name)
JOIN cinema.movies m
ON m.title = x.movie_title
JOIN cinema.genres g
ON g.genre_name = x.genre_name;

INSERT INTO cinema.screenings (
    movie_id,
    hall_id,
    screening_time
)
VALUES
(
    (SELECT movie_id
     FROM cinema.movies
     WHERE title = 'Interstellar'),

    (SELECT hall_id
     FROM cinema.halls
     WHERE hall_title = 'Hall A'),

    TIMESTAMP '2026-06-01 18:00:00'
),
(
    (SELECT movie_id
     FROM cinema.movies
     WHERE title = 'Dune Part Two'),

    (SELECT hall_id
     FROM cinema.halls
     WHERE hall_title = 'Hall B'),

    TIMESTAMP '2026-06-02 20:00:00'
),
(
    (SELECT movie_id
     FROM cinema.movies
     WHERE title = 'Avatar Fire and Ash'),

    (SELECT hall_id
     FROM cinema.halls
     WHERE hall_title = 'Hall C'),

    TIMESTAMP '2026-06-03 21:00:00'
);

INSERT INTO cinema.customers (
    full_name,
    email,
    gender,
    loyalty_status,
    phone_number
)
VALUES
(
    'Temirlan Gizatov',
    'temirlan@gmail.com',
    'M',
    'gold',
    '+77771234567'
),
(
    'Aigerim Tolegen',
    'aigerim@gmail.com',
    'F',
    'regular',
    '+77779876543'
),
(
    'Nursultan Omarov',
    'nursultan@gmail.com',
    'M',
    'premium',
    '+77005554433'
);

INSERT INTO cinema.bookings (
    customer_id,
    screening_id,
    booking_status
)
VALUES
(
    (SELECT customer_id
     FROM cinema.customers
     WHERE email = 'temirlan@gmail.com'),

    (SELECT screening_id
     FROM cinema.screenings s
     JOIN cinema.movies m
     ON s.movie_id = m.movie_id
     WHERE m.title = 'Interstellar'),

    'confirmed'
),
(
    (SELECT customer_id
     FROM cinema.customers
     WHERE email = 'aigerim@gmail.com'),

    (SELECT screening_id
     FROM cinema.screenings s
     JOIN cinema.movies m
     ON s.movie_id = m.movie_id
     WHERE m.title = 'Dune Part Two'),

    'pending'
),
(
    (SELECT customer_id
     FROM cinema.customers
     WHERE email = 'nursultan@gmail.com'),

    (SELECT screening_id
     FROM cinema.screenings s
     JOIN cinema.movies m
     ON s.movie_id = m.movie_id
     WHERE m.title = 'Avatar Fire and Ash'),

    'confirmed'
);

INSERT INTO cinema.tickets (
    booking_id,
    seat_count,
    price_per_seat
)
VALUES
(
    (SELECT booking_id
     FROM cinema.bookings b
     JOIN cinema.customers c
     ON b.customer_id = c.customer_id
     WHERE c.email = 'temirlan@gmail.com'),

    2,
    4500
),
(
    (SELECT booking_id
     FROM cinema.bookings b
     JOIN cinema.customers c
     ON b.customer_id = c.customer_id
     WHERE c.email = 'aigerim@gmail.com'),

    1,
    5000
),
(
    (SELECT booking_id
     FROM cinema.bookings b
     JOIN cinema.customers c
     ON b.customer_id = c.customer_id
     WHERE c.email = 'nursultan@gmail.com'),

    3,
    5500
);

-- ============================================================
-- PART 5: UPDATE
-- ============================================================

-- premium customers receive VIP status
UPDATE cinema.customers
SET loyalty_status = 'vip'
WHERE email = 'temirlan@gmail.com';

-- recalculate booking totals from tickets
UPDATE cinema.bookings b
SET total_amount = sub.new_total
FROM (
    SELECT
        booking_id,
        SUM(total_price) AS new_total
    FROM cinema.tickets
    GROUP BY booking_id
) sub
WHERE b.booking_id = sub.booking_id;

-- ============================================================
-- PART 5: DELETE
-- ============================================================

-- remove cancelled bookings for demonstration
BEGIN;

DELETE FROM cinema.bookings
WHERE booking_status = 'cancelled'
RETURNING booking_id, customer_id;

ROLLBACK;

-- ============================================================
-- PART 6: GRANT / REVOKE
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'cinema_readonly'
    ) THEN
        REASSIGN OWNED BY cinema_readonly TO CURRENT_USER;
        DROP OWNED BY cinema_readonly;
        DROP ROLE cinema_readonly;
    END IF;

    IF EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'cinema_writer'
    ) THEN
        REASSIGN OWNED BY cinema_writer TO CURRENT_USER;
        DROP OWNED BY cinema_writer;
        DROP ROLE cinema_writer;
    END IF;
END $$;

CREATE ROLE cinema_readonly;
CREATE ROLE cinema_writer;

GRANT USAGE ON SCHEMA cinema
TO cinema_readonly, cinema_writer;

GRANT SELECT ON ALL TABLES IN SCHEMA cinema
TO cinema_readonly;

GRANT INSERT, UPDATE ON cinema.bookings
TO cinema_writer;

-- writers should not update bookings after confirmation
REVOKE UPDATE ON cinema.bookings
FROM cinema_writer;