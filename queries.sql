-- J&J's Library – Example queries
USE library;

-- 1. Overdue books with member contact info
SELECT m.first_name, m.last_name, m.email, b.title, c.due_date,
       DATEDIFF(CURRENT_DATE, c.due_date) AS days_overdue
FROM checkouts c
JOIN members m ON m.member_id = c.member_id
JOIN books   b ON b.book_id   = c.book_id
WHERE c.return_date IS NULL AND c.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- 2. Late-return rate (replaces the stored "Late" column)
SELECT COUNT(*) AS returned,
       SUM(return_date > due_date) AS returned_late,
       ROUND(100 * SUM(return_date > due_date) / COUNT(*), 1) AS pct_late
FROM checkouts
WHERE return_date IS NOT NULL;

-- 3. Copies available per book
SELECT b.title, b.quantity,
       b.quantity - COUNT(c.checkout_id) AS available
FROM books b
LEFT JOIN checkouts c ON c.book_id = b.book_id AND c.return_date IS NULL
GROUP BY b.book_id, b.title, b.quantity;

-- 4. Checkouts by genre and section
SELECT g.name AS genre, s.name AS section, COUNT(c.checkout_id) AS checkouts
FROM books b
JOIN genres g        ON g.genre_id   = b.genre_id
JOIN sections s      ON s.section_id = b.section_id
LEFT JOIN checkouts c ON c.book_id   = b.book_id
GROUP BY g.name, s.name
ORDER BY checkouts DESC;

-- 5. Equipment value by building and room
SELECT bl.name AS building, r.room_number,
       COUNT(e.equipment_id) AS items, SUM(e.cost) AS total_cost
FROM buildings bl
JOIN rooms r          ON r.building_id = bl.building_id
LEFT JOIN equipment e ON e.room_id     = r.room_id
GROUP BY bl.name, r.room_number;

-- 6. Data-quality check: members missing phone or address
SELECT member_id, first_name, last_name, email,
       phone_number IS NULL AS missing_phone,
       address IS NULL      AS missing_address
FROM members
WHERE phone_number IS NULL OR address IS NULL;
