# LMS Database Design (MSSQL)

A relational database project for a university Learning Management System (LMS), developed using Microsoft SQL Server (T-SQL).

## Project Overview

This project models the core database structure of a university LMS, including departments, instructors, students, courses, grades, virtual classrooms, assignments, and exams.

## What is Included?

- **Database Tables & Constraints:** 8 related tables (`bolumler`, `akademisyenler`, `ogrenciler`, `dersler`, `notlar`, `sanal_siniflar`, `odevler`, `sinavlar`) connected with `PRIMARY KEY` and `FOREIGN KEY` relationships, plus `CHECK` constraints for grade (0–100) and class year (1–4) validation.
- **Sample Data:** Initial `INSERT` queries to populate departments, instructors, student records, and course grades.
- **Student Course View:** A `VIEW` (`vw_OgrenciTumDersler`) using `INNER JOIN` to display a student's department, enrolled courses, instructors, and exam scores in one place.
- **User Roles & Permissions:** Basic role-based security (`rol_ogrenci` and `rol_akademisyen`) using `GRANT` statements so students can only view their course summary while instructors can manage grades, assignments, and exams.

## How to Run

1. Open **SQL Server Management Studio (SSMS)**.
2. Open `LMS_Database.sql` (or `SQLQuery2.sql`).
3. Press **F5** (Execute) to create the `LMS_DB` database, insert the sample data, and test the view.
