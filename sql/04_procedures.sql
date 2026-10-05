USE DutyRotation;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GenerateRotation
    @StartDate DATE,
    @Months    INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Months < 1 OR @Months > 12
        THROW 50001, 'Months must be between 1 and 12.', 1;

    DECLARE @EmployeeCount INT = (SELECT COUNT(*) FROM dbo.Employees);

    IF @EmployeeCount = 0
        THROW 50002, 'There are no employees to build a rotation from.', 1;

    DECLARE @EndDate     DATE = DATEADD(MONTH, @Months, @StartDate);
    DECLARE @CurrentDate DATE = @StartDate;
    DECLARE @PreviousEmployeeId INT = (SELECT EmployeeId FROM dbo.DutyAssignments WHERE DutyDate = DATEADD(DAY, -1, @StartDate));
    DECLARE @Pointer INT = ISNULL((SELECT RotationOrder FROM dbo.Employees WHERE EmployeeId = @PreviousEmployeeId) + 1, 1);
    DECLARE @EmployeeId  INT;

    /* Regenerating must not collide with rows that are already there. */
    DELETE FROM dbo.DutyAssignments WHERE DutyDate >= @StartDate;

    /* Days are assigned one by one: leave shifts the rotation (BR-4), so each
       day depends on who was on duty the day before. That makes this step
       inherently sequential, hence a loop instead of a set-based INSERT. */
    WHILE @CurrentDate < @EndDate
    BEGIN
        SET @EmployeeId = dbo.fn_NextAvailableEmployee(@Pointer, @CurrentDate) ;

        IF @EmployeeId IS NULL
            THROW 50003, 'No employee is available on at least one day (BR-8).', 1;

        INSERT INTO dbo.DutyAssignments (DutyDate, EmployeeId)
        VALUES (@CurrentDate, @EmployeeId);

        SET @Pointer = (SELECT RotationOrder FROM dbo.Employees WHERE EmployeeId = @EmployeeId) + 1;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END
GO