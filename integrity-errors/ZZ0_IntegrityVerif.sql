SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZZ0_IntegrityVerif]
    @Mode varchar(50) = 'SelectLive' -- 'SelectLive', 'UpdateLog', 'SelectLog'
  , @ErrorCode varchar(10) = '%'
AS
BEGIN

IF (@Mode = 'SelectLog') BEGIN
  SELECT r.[Group], r.[ErrorCode], c.[ErrorDesc], r.[ErrorDetails], r.[PK1], r.[PK2], r.[OpenDate], r.[CloseDate]
    FROM dbo.[ZZ0_IntegrityLog] r
    LEFT JOIN dbo.[ZZ0_IntegrityConfig] c ON c.[ErrorCode] = r.[ErrorCode]
    WHERE r.[ErrorCode] LIKE @ErrorCode
    ORDER BY [ErrorCode], [Group], [PK1], [PK2];

    RETURN;
END;

--String array to store list of ErrorCodes to be processed
DECLARE @tblErrorCodes TABLE( [ErrorCode] varchar(5) );
INSERT INTO @tblErrorCodes SELECT [ErrorCode] FROM dbo.[ZZ0_IntegrityConfig] WHERE [IsEnabled] = 1 AND [ErrorCode] LIKE @ErrorCode;

--Loop variables declaration
DECLARE @strErrorCode varchar(5), @strQuery varchar(MAX);
DECLARE @tblResult TABLE (
    [ErrorCode]    varchar(5),
    [ErrorDetails] varchar(8000),
    [Group]        int,
    [PK1]          sql_variant,
    [PK2]          sql_variant
);

WHILE EXISTS(SELECT 1 FROM @tblErrorCodes)
BEGIN
    --Get error code to process
    SELECT TOP 1 @strErrorCode = [ErrorCode] FROM @tblErrorCodes;
    
    --Get query for this error code
    SELECT @strQuery = [Query] FROM dbo.[ZZ0_IntegrityConfig] WHERE [ErrorCode] = @strErrorCode;

    --Fill result table
    DELETE FROM @tblResult;
    INSERT INTO @tblResult EXECUTE(@strQuery);

    --Update ZZ0_IntegrityLog
    IF (@Mode = 'UpdateLog') BEGIN
        --Update existing ErrorLogs (still open or closed)
        UPDATE dbo.[ZZ0_IntegrityLog]
           SET [ErrorDetails] = CASE WHEN r.[PK1] IS NULL THEN l.[ErrorDetails] ELSE r.[ErrorDetails] END
             , [Group]        = CASE WHEN r.[PK1] IS NULL THEN 0                ELSE r.[Group]        END
             , [CloseDate]    = CASE WHEN r.[PK1] IS NULL THEN GETDATE()        ELSE NULL             END
          FROM dbo.[ZZ0_IntegrityLog] l
          LEFT JOIN @tblResult r ON r.[PK1] = l.[PK1] AND IsNull(r.[PK2],'') = l.[PK2]
         WHERE l.[ErrorCode] = @strErrorCode AND l.[CloseDate] IS NULL;

        --Insert new ErrorLogs
        INSERT INTO dbo.[ZZ0_IntegrityLog] ([ErrorCode],[ErrorDetails],[Group],[PK1],[PK2],[OpenDate])
        SELECT @strErrorCode,r.[ErrorDetails],r.[Group],r.[PK1],IsNull(r.[PK2],''),GETDATE()
          FROM @tblResult r
          LEFT JOIN dbo.[ZZ0_IntegrityLog] l ON l.[ErrorCode] = @strErrorCode AND l.[PK1] = r.[PK1] AND l.[PK2] = IsNull(r.[PK2],'') AND l.[CloseDate] IS NULL
         WHERE l.[PK1] IS NULL;

        UPDATE dbo.[ZZ0_IntegrityConfig]
           SET [LastLogUpdate] = GETDATE(), [NbOpenCases] = (SELECT COUNT('') FROM @tblResult)
         WHERE [ErrorCode] = @strErrorCode;

         SELECT @strErrorCode;
    END
    --Return errors
    ELSE IF (@Mode = 'SelectLive') BEGIN
        SELECT r.[Group], @strErrorCode AS [ErrorCode], c.[ErrorDesc], r.[ErrorDetails], r.[PK1], r.[PK2]
          FROM @tblResult r
          LEFT JOIN dbo.[ZZ0_IntegrityConfig] c ON c.[ErrorCode] = @strErrorCode
         ORDER BY [ErrorCode], [Group], [PK1], [PK2];
    END

    --Remove processed error code from string array
    DELETE FROM @tblErrorCodes WHERE [ErrorCode] = @strErrorCode;
END;

END
GO