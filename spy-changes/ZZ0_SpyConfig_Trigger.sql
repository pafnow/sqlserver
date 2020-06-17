SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[ZZ0_SpyConfig_Trigger]
  ON [dbo].[ZZ0_SpyConfig]
  AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
  SET NOCOUNT ON;

  -- CountRec, SqlAction --
  DECLARE @CountIns int = (SELECT COUNT('') FROM inserted);
  DECLARE @CountDel int = (SELECT COUNT('') FROM deleted);
  DECLARE @CountRec int = CASE WHEN @CountIns >= @CountDel THEN @CountIns ELSE @CountDel END;
  IF (@CountRec = 0) RETURN; --Exit quand la clause WHERE ne ramène aucun enregistrement
  DECLARE @SqlAction varchar(6) = CASE WHEN @CountIns = 0 AND @CountDel = 0 THEN '(NONE)'
                                       WHEN @CountIns <>0 AND @CountDel = 0 THEN 'INSERT'
                                       WHEN @CountIns <>0 AND @CountDel <>0 THEN 'UPDATE'
                                       WHEN @CountIns = 0 AND @CountDel <>0 THEN 'DELETE' 
                                  ELSE '' END;

  DECLARE @SqlCmd varchar(MAX);

  -- DELETE Spy triggers --
  IF (@SqlAction IN ('DELETE'))
  BEGIN
    SELECT @SqlCmd = STRING_AGG('DROP TRIGGER IF EXISTS '+SchemaName+'.'+TriggerName+'; ',CHAR(13)+CHAR(10))
      FROM deleted;
   EXEC (@SqlCmd);
  END;

  -- CREATE/UPDATE Spy triggers --
  IF (@SqlAction IN ('INSERT','UPDATE'))
  BEGIN
    -- ALLOW ONLY 1 record UPDATE --
    IF (@CountRec > 1)
    BEGIN
      ROLLBACK;
      RAISERROR('Cannot insert or update more than one record in SpyConfig at the same time.',17,1);
      RETURN;
    END;

    --Fetch information from updated record (only one here)
    DECLARE @SchemaName varchar(255), @TableName varchar(255), @TriggerName varchar(255), @ColumnsToSpy varchar(MAX);
    SELECT @SchemaName=SchemaName, @TableName=TableName, @TriggerName=TriggerName, @ColumnsToSpy=ColumnsToSpy FROM inserted;

    DECLARE @FieldsPK varchar(MAX), @JoinPK varchar(MAX);
    SELECT @FieldsPK = STRING_AGG('i.['+[name]+']','+'',''+')
         , @JoinPK   = STRING_AGG('i.['+[name]+']=d.['+[name]+']',' AND ')
      FROM (SELECT COL_NAME(ic.[object_id],ic.[column_id]) AS [name]
              FROM sys.indexes i 
              JOIN sys.index_columns ic ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id]
             WHERE i.[is_primary_key] = 1
               AND i.[object_id] = OBJECT_ID(@SchemaName+'.'+@TableName)
           ) a;

    DECLARE @FieldsChanges varchar(MAX) = (
      SELECT STRING_AGG(CONVERT(varchar(MAX)
                       ,'CASE WHEN _._.fn_StrComp(d.['+[name]+']'+SPACE(nameLenMax-nameLen)+',i.['+[name]+']'+SPACE(nameLenMax-nameLen)+',1)=1 THEN '''' '
                       +'ELSE ''['+[name]+']:'''+SPACE(nameLenMax-nameLen)+'+IsNull(CONVERT(varchar(MAX),d.['+[name]+']'+SPACE(nameLenMax-nameLen)+',120),''Null'')'
                                                                   +'+''=>''+IsNull(CONVERT(varchar(MAX),i.['+[name]+']'+SPACE(nameLenMax-nameLen)+',120),''Null'') END'
                       ),CHAR(13)+CHAR(10)+'       + ')
        FROM (SELECT [name], LEN([name]) AS nameLen, MAX(LEN([name])) OVER (PARTITION BY [object_id]) AS nameLenMax
                FROM sys.[columns]
               WHERE [is_identity] <> 1 AND [is_computed] <> 1
                 AND [system_type_id] <> 165 --varbinary
                 AND [object_id] = OBJECT_ID(@SchemaName+'.'+@TableName)
                 AND [name] LIKE @ColumnsToSpy
             ) a );

    SET @SqlCmd = 
      + 'CREATE OR ALTER TRIGGER '+@SchemaName+'.'+@TriggerName+' ON '+@SchemaName+'.'+@TableName+' AFTER INSERT,DELETE,UPDATE AS' + CHAR(13)+CHAR(10)
      + 'BEGIN' + CHAR(13)+CHAR(10)
      + '  SET NOCOUNT ON;' + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10)
      + '  -- QUIT IF NESTED EXECUTION --' + CHAR(13)+CHAR(10)
      + '  IF TRIGGER_NESTLEVEL()<>1 RETURN;' + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10)
      + '  -- CountRec, SqlAction --' + CHAR(13)+CHAR(10)
      + '  DECLARE @CountIns int = (SELECT COUNT(1) FROM inserted);' + CHAR(13)+CHAR(10)
      + '  DECLARE @CountDel int = (SELECT COUNT(1) FROM deleted);' + CHAR(13)+CHAR(10)
      + '  DECLARE @CountRec int = CASE WHEN @CountIns >= @CountDel THEN @CountIns ELSE @CountDel END;' + CHAR(13)+CHAR(10)
      + '  IF (@CountRec = 0) RETURN; --Exit quand la clause WHERE ne ramène aucun enregistrement' + CHAR(13)+CHAR(10)
      + '  DECLARE @SqlAction varchar(6) = CASE WHEN @CountIns = 0 AND @CountDel = 0 THEN ''(NONE)''' + CHAR(13)+CHAR(10)
      + '                                       WHEN @CountIns <>0 AND @CountDel = 0 THEN ''INSERT''' + CHAR(13)+CHAR(10)
      + '                                       WHEN @CountIns <>0 AND @CountDel <>0 THEN ''UPDATE''' + CHAR(13)+CHAR(10)
      + '                                       WHEN @CountIns = 0 AND @CountDel <>0 THEN ''DELETE''' + CHAR(13)+CHAR(10)
      + '                                  ELSE '''' END;' + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10)
      + '  INSERT INTO ZZ0_Spy ([TableName], [SqlAction], [CountRec], [PrimaryKey], [Changes])' + CHAR(13)+CHAR(10)
      + '  SELECT '''+@TableName+''', LEFT(@SqlAction,1), @CountRec' + CHAR(13)+CHAR(10)
      + '       , '+@FieldsPK      + CHAR(13)+CHAR(10)
      + '       , '+@FieldsChanges + CHAR(13)+CHAR(10)
      + '    FROM inserted i' + CHAR(13)+CHAR(10)
      + '    LEFT JOIN deleted d ON ' + @JoinPK + CHAR(13)+CHAR(10)
      + 'END;' + CHAR(13)+CHAR(10);
    EXEC (@SqlCmd);
    RETURN;
  END;
END
GO

ALTER TABLE [dbo].[ZZ0_SpyConfig] ENABLE TRIGGER [ZZ0_SpyConfig_Trigger]
GO