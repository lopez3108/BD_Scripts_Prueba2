SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCountries](@HasCurrency BIT = NULL)
AS
    BEGIN
        SELECT [CountryId], 
              upper ([Name]) as Name, 
               Currency, 
               Currency,
			   CountryAbre
        FROM [dbo].[Countries]
        WHERE(@HasCurrency IS NULL
              OR @HasCurrency = 0)
             OR (@HasCurrency = 1
                 AND Currency IS NOT NULL)
				  ORDER BY Name 
    END;
GO