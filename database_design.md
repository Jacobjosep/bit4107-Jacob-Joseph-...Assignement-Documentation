# Week 7 Task 2: Student Database Design

## Designing the Student Database

I designed a database for a university student management system. This is what I came up with:

### What Tables Do We Need?

After thinking about it, I realized we need three main tables:

### 1. Students Table
This holds all the student information:
- student_id: A unique number for each student (primary key)
- registration_number: The official student number (must be unique)
- first_name and last_name: Split so we can search by last name
- course_code: Which course they are taking
- year_of_study: 1st year, 2nd year, etc.
- phone_number: Contact info
- email: Another way to reach them
- password_hash: Stores the password securely
- enrollment_date: When they joined

### 2. Courses Table
This stores information about each course:
- course_code: e.g., BIT4107 (primary key)
- course_name: e.g., Mobile Application Development
- credits: How many credit hours
- department: Which department offers it

### 3. Enrollment Table
This connects students to courses:
- enrollment_id: Unique ID for each enrollment record
- student_id: Links to the Students table
- course_code: Links to the Courses table
- semester: When they took the course
- grade: Their final grade (if available)

### Normalization
I used three levels of normalization:

**1NF (First Normal Form)**
I split names into first_name and last_name. Each piece of data is broken down into its smallest parts.

**2NF (Second Normal Form)**
I separated student info and course info into different tables. If a student changes their phone number, we only update it in one place.

**3NF (Third Normal Form)**
Everything in each table depends only on that table's primary key.

### Password Security - BCrypt Hashing
Instead of storing the actual password, I store a "hash" (scrambled version that can't be reversed). BCrypt automatically adds random data to make each hash unique.

### Sample SQL Code
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    registration_number TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    course_code TEXT NOT NULL,
    year_of_study INTEGER NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT UNIQUE,
    password_hash TEXT NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE courses (
    course_code TEXT PRIMARY KEY,
    course_name TEXT NOT NULL,
    credits INTEGER NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE enrollment (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_code TEXT NOT NULL,
    semester TEXT NOT NULL,
    grade TEXT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_code) REFERENCES courses(course_code)
);

### Useful Queries

Get all students in BIT4107:
SELECT first_name, last_name, registration_number
FROM students
WHERE course_code = "BIT4107";

Student enrollment report:
SELECT s.first_name || " " || s.last_name AS name,
       c.course_name,
       e.semester,
       e.grade
FROM students s
JOIN enrollment e ON s.student_id = e.student_id
JOIN courses c ON e.course_code = c.course_code
WHERE s.student_id = 1;
