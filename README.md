# J&J’s Library – Cloud Database Project

A library management database and web app, built in 2023 as a two-person academic project at Grambling State University (with Jonathan Smith) and refined in 2026.

## What we built (2023)

- **ERD design** covering 9 entities: Buildings, Rooms, Equipment, Sections, Staff, Members, Books, Genres, and Checkout
- **Table definitions** with primary keys and attributes for Books, Employees (Staff), and Buildings
- **PHP + MySQL web app on AWS EC2** with Home, Sign Up, and Book Search pages; the sign-up form wrote member records to MySQL through PHP

## Refinements (2026)

Reviewing the original ERD, I implemented it as working SQL and fixed these design gaps:

|Original design                 |Refinement                                  |Why                                                                  |
|--------------------------------|--------------------------------------------|---------------------------------------------------------------------|
|Checkout had no primary key     |Added `checkout_id`                         |Every row needs a unique identifier                                  |
|Members linked directly to Books|Linked through `checkouts`                  |A member–book relationship is many-to-many and needs a junction table|
|Author stored as text on Books  |Separate `authors` table + `book_authors`   |Supports multiple authors and avoids duplicate spellings             |
|`Late` stored as a field        |Calculated from `due_date` and `return_date`|Stored flags go stale; derived values stay accurate                  |

Constraints (`UNIQUE`, `CHECK`, foreign keys) enforce data integrity across all 11 tables.

## ERD

```mermaid
erDiagram
    BUILDINGS ||--|{ ROOMS : contains
    STAFF |o--o{ BUILDINGS : manages
    ROOMS ||--o{ EQUIPMENT : holds
    ROOMS ||--o{ SECTIONS : houses
    STAFF |o--o{ SECTIONS : oversees
    SECTIONS ||--o{ BOOKS : shelves
    GENRES ||--o{ BOOKS : classifies
    BOOKS ||--|{ BOOK_AUTHORS : has
    AUTHORS ||--|{ BOOK_AUTHORS : writes
    MEMBERS ||--o{ CHECKOUTS : makes
    BOOKS ||--o{ CHECKOUTS : "is checked out in"

    BUILDINGS {
        int building_id PK
        varchar name
        varchar address
        int manager_staff_id FK
    }
    ROOMS {
        int room_id PK
        varchar room_number
        int building_id FK
    }
    EQUIPMENT {
        int equipment_id PK
        varchar type
        decimal cost
        smallint lifespan_years
        int room_id FK
    }
    SECTIONS {
        int section_id PK
        varchar name
        int staff_id FK
        int room_id FK
    }
    STAFF {
        int staff_id PK
        varchar first_name
        varchar last_name
        varchar job_title
        varchar email UK
    }
    GENRES {
        int genre_id PK
        varchar name UK
    }
    AUTHORS {
        int author_id PK
        varchar first_name
        varchar last_name
    }
    BOOKS {
        int book_id PK
        varchar isbn UK
        varchar title
        varchar publisher
        int quantity
        int genre_id FK
        int section_id FK
    }
    BOOK_AUTHORS {
        int book_id PK, FK
        int author_id PK, FK
    }
    MEMBERS {
        int member_id PK
        varchar first_name
        varchar last_name
        varchar email UK
        varchar phone_number
    }
    CHECKOUTS {
        int checkout_id PK
        int member_id FK
        int book_id FK
        datetime checkout_datetime
        date due_date
        date return_date
    }
```

## Files

- `schema.sql`: creates all tables, keys, constraints, and sample data
- `queries.sql`: overdue books, late-return rate, availability, checkouts by genre and section, equipment value by room, and a data-quality check

## Run it

```bash
mysql -u root -p < schema.sql
mysql -u root -p < queries.sql
```

## Tools

MySQL, SQL, ERD modeling, PHP, AWS EC2
