ALTER TABLE Members
ALTER COLUMN username SET NOT NULL;

ALTER TABLE Members
ALTER COLUMN email SET NOT NULL;

ALTER TABLE Members
ALTER COLUMN is_active SET DEFAULT true;

ALTER TABLE Members
ADD CONSTRAINT members_username_unique UNIQUE (username);

ALTER TABLE Members
ADD CONSTRAINT members_email_unique UNIQUE (email);


/* =========================
   BOOKS FIXES
========================= */

ALTER TABLE Books
ALTER COLUMN author SET NOT NULL;

ALTER TABLE Books
ADD CONSTRAINT books_year_check CHECK (year_pub >= 0);

-- Add condition column (first as TEXT for bonus step)
ALTER TABLE Books
ADD COLUMN condition TEXT DEFAULT 'good';

-- Change type (BONUS)
ALTER TABLE Books
ALTER COLUMN condition TYPE VARCHAR(30);

-- Make it NOT NULL
ALTER TABLE Books
ALTER COLUMN condition SET NOT NULL;

-- Add FK
ALTER TABLE Books
ADD CONSTRAINT books_owner_fk
FOREIGN KEY (owner_id) REFERENCES Members(id);

ALTER TABLE Exchanges
ALTER COLUMN exchange_date SET NOT NULL;

ALTER TABLE Exchanges
ADD CONSTRAINT exchanges_date_check
CHECK (exchange_date >= '2026-01-01');

ALTER TABLE Exchanges
ADD CONSTRAINT exchanges_return_check
CHECK (return_date >= '2026-01-01');

-- Add status column
ALTER TABLE Exchanges
ADD COLUMN status VARCHAR(20) DEFAULT 'pending';

-- Add FKs
ALTER TABLE Exchanges
ADD CONSTRAINT exchanges_book_fk
FOREIGN KEY (book_id) REFERENCES Books(id);

ALTER TABLE Exchanges
ADD CONSTRAINT exchanges_borrower_fk
FOREIGN KEY (borrower_id) REFERENCES Members(id);

ALTER TABLE Reviews
ALTER COLUMN review_text SET NOT NULL;

ALTER TABLE Reviews
ADD CONSTRAINT reviews_rating_check
CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE Reviews
ADD CONSTRAINT reviews_book_fk
FOREIGN KEY (book_id) REFERENCES Books(id);

ALTER TABLE Reviews
ADD CONSTRAINT reviews_member_fk
FOREIGN KEY (member_id) REFERENCES Members(id);
