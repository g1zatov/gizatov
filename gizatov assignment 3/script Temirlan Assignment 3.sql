BEGIN;

WITH new_movies AS (
    SELECT
        'Inception' AS title,
        'A skilled thief who steals corporate secrets through dream-sharing technology '
        || 'is given the inverse task of planting an idea into the mind of a CEO.' AS description,
        2010 AS release_year,
        (SELECT language_id FROM language WHERE lower(name) = 'english') AS language_id,
        7 AS rental_duration,
        4.99 AS rental_rate,
        148 AS length,
        'PG-13'::mpaa_rating AS rating

    UNION ALL

    SELECT
        'The Dark Knight' AS title,
        'Batman faces the Joker, a criminal mastermind who plunges Gotham City into chaos '
        || 'and forces the Dark Knight closer to crossing the fine line between hero and vigilante.' AS description,
        2008 AS release_year,
        (SELECT language_id FROM language WHERE lower(name) = 'english') AS language_id,
        14 AS rental_duration,
        9.99 AS rental_rate,
        152 AS length,
        'PG-13'::mpaa_rating AS rating

    UNION ALL

    SELECT
        'Interstellar' AS title,
        'A team of explorers travel through a wormhole in space in an attempt '
        || 'to ensure humanity''s survival.' AS description,
        2014 AS release_year,
        (SELECT language_id FROM language WHERE lower(name) = 'english') AS language_id,
        21 AS rental_duration,
        19.99 AS rental_rate,
        169 AS length,
        'PG-13'::mpaa_rating AS rating
),

inserted_movies AS (
    INSERT INTO film
        (title, description, release_year, language_id,
         rental_duration, rental_rate, length, rating, last_update)
    SELECT
        nm.title, nm.description, nm.release_year, nm.language_id,
        nm.rental_duration, nm.rental_rate, nm.length, nm.rating,
        CURRENT_DATE
    FROM new_movies nm
    WHERE NOT EXISTS (
        SELECT 1 FROM film f
        WHERE f.title = nm.title AND f.release_year = nm.release_year
    )
    RETURNING film_id, title, release_year, rental_duration, rental_rate, last_update
)
SELECT film_id, title, release_year, rental_duration, rental_rate, last_update
FROM inserted_movies;

SELECT film_id, title, release_year, rental_duration, rental_rate, rating, last_update
FROM film
WHERE title IN ('Inception', 'The Dark Knight', 'Interstellar')
  AND release_year IN (2010, 2008, 2014);



INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Leonardo', 'DiCaprio', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Leonardo' AND last_name = 'DiCaprio');

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Joseph', 'Gordon-Levitt', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Joseph' AND last_name = 'Gordon-Levitt');

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Elliot', 'Page', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Elliot' AND last_name = 'Page');


INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Christian', 'Bale', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Christian' AND last_name = 'Bale');

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Heath', 'Ledger', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Heath' AND last_name = 'Ledger');


INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Matthew', 'McConaughey', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM actor WHERE first_name = 'Matthew' AND last_name = 'McConaughey');


SELECT actor_id, first_name, last_name, last_update
FROM actor
WHERE (first_name = 'Leonardo' AND last_name = 'DiCaprio')
   OR (first_name = 'Joseph' AND last_name = 'Gordon-Levitt')
   OR (first_name = 'Elliot' AND last_name = 'Page')
   OR (first_name = 'Christian' AND last_name = 'Bale')
   OR (first_name = 'Heath' AND last_name = 'Ledger')
   OR (first_name = 'Matthew' AND last_name = 'McConaughey');



INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Leonardo' AND last_name = 'DiCaprio'),
    (SELECT film_id  FROM film  WHERE title = 'Inception' AND release_year = 2010),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Joseph' AND last_name = 'Gordon-Levitt'),
    (SELECT film_id  FROM film  WHERE title = 'Inception' AND release_year = 2010),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Elliot' AND last_name = 'Page'),
    (SELECT film_id  FROM film  WHERE title = 'Inception' AND release_year = 2010),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Christian' AND last_name = 'Bale'),
    (SELECT film_id  FROM film  WHERE title = 'The Dark Knight' AND release_year = 2008),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Heath' AND last_name = 'Ledger'),
    (SELECT film_id  FROM film  WHERE title = 'The Dark Knight' AND release_year = 2008),
    CURRENT_DATE
ON CONFLICT DO NOTHING;


INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (SELECT actor_id FROM actor WHERE first_name = 'Matthew' AND last_name = 'McConaughey'),
    (SELECT film_id  FROM film  WHERE title = 'Interstellar' AND release_year = 2014),
    CURRENT_DATE
ON CONFLICT DO NOTHING;



INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010),
    (SELECT MIN(store_id) FROM store),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id  = (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010)
      AND store_id = (SELECT MIN(store_id) FROM store)
);

INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'The Dark Knight' AND release_year = 2008),
    (SELECT MIN(store_id) FROM store),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id  = (SELECT film_id FROM film WHERE title = 'The Dark Knight' AND release_year = 2008)
      AND store_id = (SELECT MIN(store_id) FROM store)
);

INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'Interstellar' AND release_year = 2014),
    (SELECT MIN(store_id) FROM store),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id  = (SELECT film_id FROM film WHERE title = 'Interstellar' AND release_year = 2014)
      AND store_id = (SELECT MIN(store_id) FROM store)
);


SELECT i.inventory_id, f.title, i.store_id, i.last_update
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title IN ('Inception', 'The Dark Knight', 'Interstellar')
  AND f.release_year IN (2010, 2008, 2014);



SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT r.rental_id)  AS rental_count,
    COUNT(DISTINCT p.payment_id) AS payment_count
FROM customer c
JOIN rental  r ON c.customer_id = r.customer_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT r.rental_id)  >= 43
   AND COUNT(DISTINCT p.payment_id) >= 43
ORDER BY rental_count DESC
LIMIT 1;


UPDATE customer
SET
    first_name  = 'Aibek',
    last_name   = 'Dzhaksybekov',
    email       = 'aibek.dzhaksybekov@sakilacustomer.org',
    address_id  = (SELECT MIN(address_id) FROM address),
    last_update = CURRENT_DATE
WHERE customer_id = (
    SELECT c.customer_id
    FROM customer c
    JOIN rental  r ON c.customer_id = r.customer_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(DISTINCT r.rental_id)  >= 43
       AND COUNT(DISTINCT p.payment_id) >= 43
    ORDER BY COUNT(DISTINCT r.rental_id) DESC
    LIMIT 1
);

SELECT customer_id, first_name, last_name, email, address_id, last_update
FROM customer
WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov';



SELECT * FROM payment
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'
);

DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'
);


SELECT * FROM rental
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'
);

DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'
);



WITH rental_inception AS (
    INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
    SELECT
        '2017-01-15 10:00:00'::TIMESTAMP,
        (
            SELECT i.inventory_id FROM inventory i
            JOIN film f ON i.film_id = f.film_id
            WHERE f.title = 'Inception' AND f.release_year = 2010
              AND i.store_id = (SELECT MIN(store_id) FROM store)
            LIMIT 1
        ),
        (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'),
        '2017-01-15 10:00:00'::TIMESTAMP + 7 * INTERVAL '1 day',
        (SELECT MIN(staff_id) FROM staff),
        CURRENT_DATE
    WHERE NOT EXISTS (
        SELECT 1 FROM rental
        WHERE customer_id  = (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov')
          AND inventory_id = (
              SELECT i.inventory_id FROM inventory i
              JOIN film f ON i.film_id = f.film_id
              WHERE f.title = 'Inception' AND f.release_year = 2010
                AND i.store_id = (SELECT MIN(store_id) FROM store)
              LIMIT 1
          )
    )
    RETURNING rental_id, customer_id
)
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    r.customer_id,
    (SELECT MIN(staff_id) FROM staff),
    r.rental_id,
    4.99,
    '2017-01-15 10:05:00'::TIMESTAMP
FROM rental_inception r
WHERE NOT EXISTS (
    SELECT 1 FROM payment p
    WHERE p.rental_id = r.rental_id AND p.customer_id = r.customer_id
)
RETURNING payment_id, customer_id, rental_id, amount, payment_date;



WITH rental_batman AS (
    INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
    SELECT
        '2017-02-10 12:00:00'::TIMESTAMP,
        (
            SELECT i.inventory_id FROM inventory i
            JOIN film f ON i.film_id = f.film_id
            WHERE f.title = 'The Dark Knight' AND f.release_year = 2008
              AND i.store_id = (SELECT MIN(store_id) FROM store)
            LIMIT 1
        ),
        (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'),
        '2017-02-10 12:00:00'::TIMESTAMP + 14 * INTERVAL '1 day',
        (SELECT MIN(staff_id) FROM staff),
        CURRENT_DATE
    WHERE NOT EXISTS (
        SELECT 1 FROM rental
        WHERE customer_id  = (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov')
          AND inventory_id = (
              SELECT i.inventory_id FROM inventory i
              JOIN film f ON i.film_id = f.film_id
              WHERE f.title = 'The Dark Knight' AND f.release_year = 2008
                AND i.store_id = (SELECT MIN(store_id) FROM store)
              LIMIT 1
          )
    )
    RETURNING rental_id, customer_id
)
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    r.customer_id,
    (SELECT MIN(staff_id) FROM staff),
    r.rental_id,
    9.99,
    '2017-02-10 12:05:00'::TIMESTAMP
FROM rental_batman r
WHERE NOT EXISTS (
    SELECT 1 FROM payment p
    WHERE p.rental_id = r.rental_id AND p.customer_id = r.customer_id
)
RETURNING payment_id, customer_id, rental_id, amount, payment_date;



WITH rental_interstellar AS (
    INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
    SELECT
        '2017-03-20 15:00:00'::TIMESTAMP,
        (
            SELECT i.inventory_id FROM inventory i
            JOIN film f ON i.film_id = f.film_id
            WHERE f.title = 'Interstellar' AND f.release_year = 2014
              AND i.store_id = (SELECT MIN(store_id) FROM store)
            LIMIT 1
        ),
        (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov'),
        '2017-03-20 15:00:00'::TIMESTAMP + 21 * INTERVAL '1 day',
        (SELECT MIN(staff_id) FROM staff),
        CURRENT_DATE
    WHERE NOT EXISTS (
        SELECT 1 FROM rental
        WHERE customer_id  = (SELECT customer_id FROM customer WHERE first_name = 'Aibek' AND last_name = 'Dzhaksybekov')
          AND inventory_id = (
              SELECT i.inventory_id FROM inventory i
              JOIN film f ON i.film_id = f.film_id
              WHERE f.title = 'Interstellar' AND f.release_year = 2014
                AND i.store_id = (SELECT MIN(store_id) FROM store)
              LIMIT 1
          )
    )
    RETURNING rental_id, customer_id
)
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    r.customer_id,
    (SELECT MIN(staff_id) FROM staff),
    r.rental_id,
    19.99,
    '2017-03-20 15:05:00'::TIMESTAMP
FROM rental_interstellar r
WHERE NOT EXISTS (
    SELECT 1 FROM payment p
    WHERE p.rental_id = r.rental_id AND p.customer_id = r.customer_id
)
RETURNING payment_id, customer_id, rental_id, amount, payment_date;


SELECT
    r.rental_id,
    f.title,
    r.rental_date,
    r.return_date,
    p.amount,
    p.payment_date
FROM rental r
JOIN inventory i  ON r.inventory_id = i.inventory_id
JOIN film f       ON i.film_id = f.film_id
JOIN payment p    ON p.rental_id = r.rental_id
WHERE r.customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Temirlan' AND last_name = 'Gizatov'
)
ORDER BY r.rental_date;

COMMIT;