USE DutyRotation;
GO

/* Returns 1 if the employee is on leave on the given date, otherwise 0. */
CREATE OR ALTER FUNCTION dbo.fn_IsOnLeave
(
    @EmployeeId INT,
    @Date       DATE
)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM dbo.LeavePeriods
        WHERE EmployeeId = @EmployeeId AND @Date BETWEEN StartDate AND EndDate
    )
        RETURN 1;

    RETURN 0;
END
GO