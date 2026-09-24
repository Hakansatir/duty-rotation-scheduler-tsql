/*
    Duty Rotation Scheduler - synthetic seed data.

    All names and leave periods below are invented for this project.
    No data from any real company is used.

    Names are alphabetical on purpose (Anna = 1, Bruno = 2, ...), so the
    generated rotation can be followed by eye when reading sample output.
*/

USE DutyRotation;
GO

/* Reset in reverse dependency order, for the same reason the schema drops
   tables children-first: a row cannot be deleted while a foreign key
   still points at it. */
DELETE FROM dbo.DutyAssignments;
DELETE FROM dbo.LeavePeriods;
DELETE FROM dbo.Employees;
GO

/* ------------------------------------------------------------------
   11 employees in the on-call rotation (BR-3).
   ------------------------------------------------------------------ */
/* Ids are written explicitly instead of relying on IDENTITY, so the seed is
   deterministic: tests and the sample output in the README refer to these
   exact ids. IDENTITY_INSERT allows writing into an identity column. */
SET IDENTITY_INSERT dbo.Employees ON;

INSERT INTO dbo.Employees (EmployeeId, FullName, RotationOrder) VALUES
    ( 1, N'Anna Weber',      1),
    ( 2, N'Bruno Fischer',   2),
    ( 3, N'Carla Mendes',    3),
    ( 4, N'David Novak',     4),
    ( 5, N'Elena Petrova',   5),
    ( 6, N'Farid Haddad',    6),
    ( 7, N'Greta Lindqvist', 7),
    ( 8, N'Hugo Martins',    8),
    ( 9, N'Irina Kovacs',    9),
    (10, N'Jonas Keller',   10),
    (11, N'Kaya Demir',     11);

SET IDENTITY_INSERT dbo.Employees OFF;
GO

/* ------------------------------------------------------------------
   Sample leave periods.

   The rotation demo starts on 2026-10-01. With 11 employees one full
   cycle is 11 days, so 2026-10-01 is Anna, 2026-10-02 is Bruno, and so on.

   Each period below exercises a specific business rule:
     1. Carla  - single day, exactly on her own duty day        (BR-4)
     2. Elena  - long leave spanning more than one cycle        (BR-4, BR-6)
     3. Hugo + Irina - overlapping leave of two people who are
        next to each other in the rotation                      (BR-5)
   ------------------------------------------------------------------ */
INSERT INTO dbo.LeavePeriods (EmployeeId, StartDate, EndDate) VALUES
    (3,  '2026-10-03', '2026-10-03'),   -- Carla: one day
    (5,  '2026-10-12', '2026-10-20'),   -- Elena: nine days
    -- Hugo and Irana's leave overlaps for 11 days (one full cycle).
    -- This guarantees that Hugo's turn comes while both are on leave (BR-5).
    (8,  '2026-11-05', '2026-11-16'),   -- Hugo
    (9,  '2026-11-06', '2026-11-17');   -- Irina: overlaps with Hugo
GO
