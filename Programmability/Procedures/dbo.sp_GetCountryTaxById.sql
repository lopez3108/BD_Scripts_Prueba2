SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountryTaxById]
(@CountryTaxId    INT  )
AS
     BEGIN
         SELECT  c.CountryTaxId,
                 c.USD,
				 c.Fee1,
				 c.CreationDate
				                        
         FROM  CountryTax c 
         WHERE c.CountryTaxId = @CountryTaxId
     END;
GO