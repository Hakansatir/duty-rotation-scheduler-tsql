/*
    Builds the whole project from scratch: schema, seed data, functions,
    procedures and a 12-month plan starting on 2026-10-01.

    Run inside the container:
        docker exec duty-rotation-sql bash -c '/opt/mssql-tools18/bin/sqlcmd
            -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -i, /sql/run_all.sql'
    
    Warning: all tables are dropped and recreated, existing data is lost.
*/

:on error EXIT
:r /sql/01_schema.sql
:r /sql/02_seed.sql
:r /sql/03_functions.sql
:r /sql/04_procedures.sql

USE DutyRotation;

EXEC dbo.usp_GenerateRotation @StartDate = '2026-10-01', @Months = 12;
GO