SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [_].[fn_StrComp]
  ( @MyString1 varchar(MAX)
  , @MyString2 varchar(MAX)
  , @MyBinary  bit = 0
  ) RETURNS bit -- Return 1 if = and 0 if <>
AS
BEGIN
  /* Unfortunatly In SQL Server the Comparaison Operator = Ignore the Trailing Spaces. */
  /* So that '' is equal to ' ' and also 'a' is equal to 'a    '. */
  /* The Current Function is created to Solve this problem. */
  /* With the Current Function 'a'<>'a  ' and also 'a'<>'à' and also 'a'<>'ä' but 'a'='A' */
  /* Send @MyBinary=1 for also make that 'a'<>'A' */
  SET @MyBinary=IsNull(@MyBinary,0);

  IF @MyString1 IS NULL     AND @MyString2 IS NULL     RETURN 1;
  IF @MyString1 IS NULL     AND @MyString2 IS NOT NULL RETURN 0;
  IF @MyString1 IS NOT NULL AND @MyString2 IS NULL     RETURN 0;

  IF @MyBinary=0  AND @MyString1+'x'=@MyString2+'x'                                         RETURN 1;
  IF @MyBinary<>0 AND CONVERT(varbinary(MAX),@MyString1)=CONVERT(varbinary(MAX),@MyString2) RETURN 1;

  RETURN 0;
END
GO
