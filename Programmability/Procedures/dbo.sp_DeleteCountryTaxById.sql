SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCountryTaxById](@CountryTaxId INT)
AS
    BEGIN
        DELETE FROM CountryTaxes
        WHERE CountryTaxId = @CountryTaxId;
    END;
GO