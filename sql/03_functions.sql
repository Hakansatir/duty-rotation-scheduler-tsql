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

/* Returns the first employee, in rotation order starting at @StartOrder
   and wrapping around, who is not on leave on @Date (BR-4, BR-5).
   Returns NULL if everyone is on leave; the caller raises the error (BR-8),
   because a function is not allowed to THROW. */
CREATE OR ALTER FUNCTION dbo.fn_NextAvailableEmployee
(
    @StartOrder INT,
    @Date       DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @EmployeeId INT;

    SELECT TOP (1) @EmployeeId = EmployeeId
    FROM dbo.Employees
    WHERE dbo.fn_IsOnLeave(EmployeeId, @Date) = 0
    ORDER BY CASE WHEN RotationOrder >= @StartOrder THEN 0 ELSE 1 END,
             RotationOrder;

    RETURN @EmployeeId;
END
GO