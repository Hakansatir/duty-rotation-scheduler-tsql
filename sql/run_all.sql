:on error EXIT
:r /sql/01_schema.sql
:r /sql/02_seed.sql
:r /sql/03_functions.sql
:r /sql/04_procedures.sql

USE DutyRotation;

EXEC dbo.usp_GenerateRotation @StartDate = '2026-10-01', @Months = 12;
GO