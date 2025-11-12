SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetEmployeeFingerPrintTemplate]
 @UserId INT
AS 

BEGIN

DECLARE @template VARCHAR(max)
SET @template = (

SELECT TOP 1 [FingerPrintTemplate]
  FROM [dbo].[Users]
  WHERE UserId = @UserId)

  SELECT @template
	
	END
GO