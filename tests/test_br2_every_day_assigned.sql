/* BR-2: every day of the plan has an employee - no day is missing.
   Two employees on one day is already impossible: DutyDate is the primary key. */
USE DutyRotation;
GO

DECLARE @PlanDays     INT = (SELECT DATEDIFF(DAY, MIN(DutyDate), MAX(DutyDate)) + 1 FROM dbo.DutyAssignments);
DECLARE @AssignedDays INT = (SELECT COUNT(*) FROM dbo.DutyAssignments);

/* An empty plan would make both counts NULL and the test would pass silently. */
IF @AssignedDays = 0
    THROW 50102, 'FAIL BR-2: the plan is empty.', 1;

DECLARE @Violations INT = @PlanDays - @AssignedDays;

IF @Violations > 0
    THROW 50102, 'FAIL BR-2: at least one day has no employee.', 1;

PRINT 'PASS BR-2: every day of the plan has an employee.';
GO
