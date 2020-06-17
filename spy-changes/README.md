# Spy Changes for SQL Server
Configurable audit trail system for any database

### Installation
Execute sql files in this exact order:
1. ZZ0_Spy.sql
2. ZZ0_SpyConfig.sql
3. ZZ0_SpyConfig_Trigger.sql
4. ZZ0_Spy_DbTrigger.sql

### Usage
- Fill the ZZ0_SpyConfig table. Each insert and update should affect only a single line in this table.
- An audit trigger is created on the table to be monitored.
- If you delete a line in ZZ0_SpyConfig, the related audit trigger will also be removed.
- Any table structure change will trigger an update of the audit trigger to make sure new/removed columns are properly monitored.
