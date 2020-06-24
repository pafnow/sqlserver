# Integrity Errors for SQL Server
Configurable data integrity audit system for any database

### Installation
Execute sql files in this exact order:
1. ZZ0_IntegrityConfig.sql
2. ZZ0_IntegrityLog.sql
3. ZZ0_IntegrityVerif.sql

### Usage
- Fill the ZZ0_IntegrityConfig table. Each line correspond to one type of error to be checked.
  - **ErrorCode**: 5 characters identifying the error
  - **ErrorDesc**: description of the error for humans to understand
  - **TableField**: optional information on where the error need to be fixed (TableName.FieldName for example)
  - **Query**: SQL query returning the list of records affected by this error<br>
  *Format*: `SELECT 'E00' AS ErrorCode, 'details' AS ErrorDetails, 1 AS Group, 'OK' AS PK1, 2 AS PK2`
- Run stored procedure ZZ0_IntegrityVerif
