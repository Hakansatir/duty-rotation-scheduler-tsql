/*
    Duty Rotation Scheduler - schema
    Business rules are documented in the README (BR-1 .. BR-8).
*/

IF DB_ID('DutyRotation') IS NULL
    CREATE DATABASE DutyRotation;
GO

USE DutyRotation;
GO

/* ------------------------------------------------------------------
   Teardown.
   Tables are dropped in reverse dependency order: children first,
   because a table cannot be dropped while a foreign key points at it.
   ------------------------------------------------------------------ */
IF OBJECT_ID('dbo.DutyAssignments', 'U') IS NOT NULL DROP TABLE dbo.DutyAssignments;
IF OBJECT_ID('dbo.LeavePeriods',    'U') IS NOT NULL DROP TABLE dbo.LeavePeriods;
IF OBJECT_ID('dbo.Employees',       'U') IS NOT NULL DROP TABLE dbo.Employees;
GO

/* ------------------------------------------------------------------
   Employees - who is in the rotation, and in which order.

   EmployeeId    : surrogate identity, carries no business meaning
   RotationOrder : the business ordering (BR-3), independent of the id
   ------------------------------------------------------------------ */
CREATE TABLE dbo.Employees
(
    EmployeeId    INT           IDENTITY(1,1) NOT NULL,
    FullName      NVARCHAR(100)               NOT NULL,
    RotationOrder INT                         NOT NULL,

    CONSTRAINT PK_Employees          PRIMARY KEY (EmployeeId),
    CONSTRAINT UQ_Employees_Rotation UNIQUE      (RotationOrder)
);
GO


/* ------------------------------------------------------------------
   LeavePeriods - when an employee is unavailable (BR-4, BR-5).
   ------------------------------------------------------------------ */
CREATE TABLE dbo.LeavePeriods
(
    LeaveId    INT  IDENTITY(1,1) NOT NULL,
    EmployeeId INT                NOT NULL,
    StartDate  DATE               NOT NULL,
    EndDate    DATE               NOT NULL,

    CONSTRAINT PK_LeavePeriods            PRIMARY KEY (LeaveId),
    CONSTRAINT FK_LeavePeriods_Employees  FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employees (EmployeeId),
    CONSTRAINT CK_LeavePeriods_DateOrder  CHECK (EndDate >= StartDate)
);
GO

CREATE TABLE dbo.DutyAssignments
(
    DutyDate    DATE               NOT NULL,
    EmployeeId  INT                NOT NULL,

    CONSTRAINT PK_DutyAssignments           PRIMARY KEY (DutyDate),
    CONSTRAINT FK_DutyAssignments_Employees FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employees (EmployeeId)
);
GO
