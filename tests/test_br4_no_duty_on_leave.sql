/* BR-4: nobody is on duty while on leave. */
USE DutyRotation;
GO

DECLARE @Violations INT = (SELECT COUNT(*) FROM dbo.DutyAssignments WHERE dbo.fn_IsOnLeave(EmployeeId, DutyDate) = 1);

IF @Violations > 0
    THROW 50104, 'FAIL BR-4: someone is on duty while on leave.', 1;

PRINT 'PASS BR-4: nobody is on duty while on leave.';
GO