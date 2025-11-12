SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAccountList]
 @Account VARCHAR(30) = NULL
AS 

BEGIN

SELECT   DISTINCT     Account
FROM            dbo.Checks
WHERE (@Account  IS NULL) OR (Account LIKE '%' + @Account + '%')
	
	
	END
GO