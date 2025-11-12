SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllZipCodes]
 
AS 

BEGIN
SELECT [ZipCode]
      ,[City]
      ,[State]
      ,[StateAbre]
      ,[County]
      ,[Latitude]
      ,[Longitude]
  FROM [dbo].[ZipCodes]
	
	END

GO