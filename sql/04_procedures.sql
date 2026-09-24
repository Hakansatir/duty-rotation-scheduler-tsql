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

    /* How many days does @Months cover? Month lengths differ, so the end
       date is computed first and the days are counted between the two. */
    DECLARE @DayCount INT = DATEDIFF(DAY, @StartDate, DATEADD(MONTH, @Months, @StartDate));

    /* Regenerating must not collide with rows that are already there. */
    DELETE FROM dbo.DutyAssignments WHERE DutyDate >= @StartDate;

    WITH Days AS (
        SELECT TOP (@DayCount)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS DayOffset
        FROM sys.all_objects
    )
    INSERT INTO dbo.DutyAssignments (DutyDate, EmployeeId)
    SELECT DATEADD(DAY, d.DayOffset, @StartDate),
           e.EmployeeId
    FROM Days AS d
    JOIN dbo.Employees AS e
        ON e.RotationOrder = (d.DayOffset % @EmployeeCount) + 1;
END
GO