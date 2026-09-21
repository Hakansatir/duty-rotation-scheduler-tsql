# Duty Rotation Scheduler (T-SQL)

A fair, leave-aware duty rotation generator built entirely in T-SQL on SQL Server 2022.

> A re-implementation, with synthetic data, of a scheduling solution I built during my
> BI & DWH internship. No company data is used here.

**Status:** work in progress — see the roadmap below.

## Roadmap

- [x] Dockerised SQL Server 2022 environment
- [ ] Schema + synthetic seed data
- [ ] Rotation generator (`sp_GenerateRotation`)
- [ ] Leave handling and re-assignment (`sp_AddLeave`)
- [ ] Test scripts
- [ ] Full documentation (business rules, ER diagram, sample output)

## Tech

SQL Server 2022 · T-SQL · Docker Compose
