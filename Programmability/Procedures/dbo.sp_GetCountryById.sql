SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetCountryById](@CountryId INT)
 
AS 

BEGIN

SELECT [CountryId]
      ,[Name]
  FROM [dbo].[Countries]
	WHERE CountryId = @CountryId
	END
GO