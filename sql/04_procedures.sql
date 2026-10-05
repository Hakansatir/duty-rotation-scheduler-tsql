USE DutyRotation;
GO

/* ------------------------------------------------------------------
   usp_AssignDuties - the rotation engine, shared by the public procedures.
   Rebuilds the plan from @FromDate (inclusive) to @ToDate (exclusive).
   ------------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE dbo.usp_AssignDuties
    @FromDate DATE,
    @ToDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = @FromDate;
    DECLARE @EmployeeId  INT;

    /* Continuity (BR-7): the rotation continues after whoever was on duty
       the day before @FromDate. With no previous day, it starts at the top. */
    DECLARE @PreviousEmployeeId INT = (SELECT EmployeeId FROM dbo.DutyAssignments WHERE DutyDate = DATEADD(DAY, -1, @FromDate));
    DECLARE @Pointer INT = ISNULL((SELECT RotationOrder FROM dbo.Employees WHERE EmployeeId = @PreviousEmployeeId) + 1, 1);

    /* Regenerating must not collide with rows that are already there. */
    DELETE FROM dbo.DutyAssignments WHERE DutyDate >= @FromDate;

    /* Days are assigned one by one: leave shifts the rotation (BR-4), so each
       day depends on who was on duty the day before. That makes this step
       inherently sequential, hence a loop instead of a set-based INSERT. */
    WHILE @CurrentDate < @ToDate
    BEGIN
        SET @EmployeeId = dbo.fn_NextAvailableEmployee(@Pointer, @CurrentDate);

        IF @EmployeeId IS NULL
            THROW 50003, 'No employee is available on at least one day (BR-8).', 1;

        INSERT INTO dbo.DutyAssignments (DutyDate, EmployeeId)
        VALUES (@CurrentDate, @EmployeeId);

        SET @Pointer = (SELECT RotationOrder FROM dbo.Employees WHERE EmployeeId = @EmployeeId) + 1;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END
GO

/* ------------------------------------------------------------------
   usp_GenerateRotation - builds a plan of 1 to 12 months.
   ------------------------------------------------------------------ */
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

    DECLARE @EndDate DATE = DATEADD(MONTH, @Months, @StartDate);

    EXEC dbo.usp_AssignDuties @FromDate = @StartDate, @ToDate = @EndDate;
END
GO
