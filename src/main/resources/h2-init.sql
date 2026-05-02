-- Match SQL Server-style schema used by JPA @Table(schema = "dbo") (H2 may resolve as DBO)
CREATE SCHEMA IF NOT EXISTS dbo;
CREATE SCHEMA IF NOT EXISTS DBO;
