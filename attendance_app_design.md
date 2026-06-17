# Week 7 Task 3: Student Attendance App

## Smart Attendance Manager - My App Concept

### What Problem Does It Solve?
Right now, many lecturers still use paper attendance sheets. Papers get lost, students can sign for friends, and generating reports takes time.

### What My App Does
1. Register students with their registration numbers and course details
2. Mark attendance with a single tap (present, absent, or late)
3. Automatically calculate attendance percentages
4. Generate reports and export them

### Why I Chose SQLite Database
1. Internet is not reliable on campus
2. Speed matters when you have 50 students
3. Structured data works best with relational databases
4. Works on any device
5. Completely free - no cloud costs

### Database Tables
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    registration_number TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    course_code TEXT NOT NULL,
    year_of_study INTEGER NOT NULL,
    phone_number TEXT NOT NULL
);

CREATE TABLE courses (
    course_code TEXT PRIMARY KEY,
    course_name TEXT NOT NULL,
    credits INTEGER NOT NULL,
    lecturer_name TEXT NOT NULL,
    department TEXT NOT NULL,
    semester TEXT NOT NULL
);

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_code TEXT NOT NULL,
    date TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ("PRESENT", "ABSENT", "LATE")),
    time_marked TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_code) REFERENCES courses(course_code),
    UNIQUE(student_id, course_code, date)
);

### Attendance Report Example

| Student Name | Present | Absent | Late | Percentage |
|--------------|---------|--------|------|------------|
| Jacob Erishlo | 12 | 0 | 1 | 92.31% |
| Mary Wanjiru | 10 | 1 | 2 | 76.92% |
| Peter Kimani | 8 | 3 | 2 | 61.54% |
