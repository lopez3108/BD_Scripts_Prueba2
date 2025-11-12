SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOfficeSuppliesProvidersList] @OfficeSupplieId INT = NULL
AS
    BEGIN
        SELECT p.ProviderName, 
        (
            SELECT Url
            FROM UrlsXProviderXSupply
            WHERE ProvidersOfficeSuppliesId = p.ProvidersOfficeSuppliesId
                  AND OfficeSupplieId = @OfficeSupplieId
        ) AS Url, 
		(
            SELECT UrlXProviderXOfficeSupplyId
            FROM UrlsXProviderXSupply
            WHERE ProvidersOfficeSuppliesId = p.ProvidersOfficeSuppliesId
                  AND OfficeSupplieId = @OfficeSupplieId
        ) AS UrlXProviderXOfficeSupplyId, 
               po.ProvidersOfficeSuppliesId, 
               po.ProvidersXOfficeSuppliesId
        FROM [dbo].ProvidersOfficeSupplies p
             INNER JOIN ProvidersXOfficeSupplies po ON po.ProvidersOfficeSuppliesId = p.ProvidersOfficeSuppliesId
        WHERE po.OfficeSupplieId = @OfficeSupplieId;
    END;
GO