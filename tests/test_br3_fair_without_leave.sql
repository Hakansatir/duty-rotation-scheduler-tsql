/* BR-3: without any leave, duty counts differ by at most one.
   The test removes all leave and regenerates the plan inside a transaction,
   then rolls back, so the database is left exactly as it was. */
USE DutyRotation;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

DELETE FROM dbo.LeavePeriods;
EXEC dbo.usp_GenerateRotation @StartDate = '2026-10-01', @Months = 12;

DECLARE @Spread INT = (
    SELECT MAX (DutyCount) - MIN (DutyCount)
    FROM (SELECT EmployeeId, COUNT(*) AS DutyCount
          FROM dbo.DutyAssignments
          GROUP BY EmployeeId) AS Counts
);

/* ROLLBACK undoes the data changes, not the variables: @Spread keeps its value. */
ROLLBACK TRANSACTION;

IF @Spread > 1
    THROW 50103, 'FAIL BR-3: without leave, duty counts differ by more than one.', 1;

PRINT 'PASS BR-3: without leave, duty counts differ by at most one.';
GO
