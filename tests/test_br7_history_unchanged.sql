/* BR-7: adding a leave re-plans only from the leave's first day;
   every day before it stays exactly as it was. Rolled back at the end. */
USE DutyRotation;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

SELECT DutyDate, EmployeeId INTO #Before FROM dbo.DutyAssignments;

/* Bruno (2) takes leave on 14-16 December 2026, inside the plan. */
EXEC dbo.usp_AddLeave @EmployeeId = 2, @StartDate = '2026-12-14', @EndDate = '2026-12-16';

DECLARE @Violations INT = (
    SELECT COUNT(*)
    FROM #Before AS b
    JOIN dbo.DutyAssignments AS d ON d.DutyDate = b.DutyDate
    WHERE b.DutyDate < '2026-12-14'
      AND b.EmployeeId <> d.EmployeeId
);

ROLLBACK TRANSACTION;

IF @Violations > 0
    THROW 50107, 'FAIL BR-7: a day before the leave changed.', 1;

PRINT 'PASS BR-7: days before the leave are unchanged.';
GO
