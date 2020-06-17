SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [ZZ0_Spy_DbTrigger]
  ON DATABASE
  FOR ALTER_TABLE, CREATE_TABLE
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @EventData XML = EVENTDATA();

  -- TRIGGER ZZ0_SpyConfig trigger --
  UPDATE ZZ0_SpyConfig SET [SchemaName] = [SchemaName] --Dummy change
   WHERE [SchemaName] = @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'VARCHAR(255)')
     AND [TableName]  = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(255)');
END
GO

ENABLE TRIGGER [ZZ0_Spy_DbTrigger] ON DATABASE
GO