SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersPayrollCheck]
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                p.Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
				CT.MaxCheckAmount,				
			 CT.Description DescriptionCheckType 
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                LEFT JOIN CheckTypesCategories ctc ON ctc.Code = 'C02' LEFT JOIN CheckTypes CT ON CT.CategoryCheckTypeId = ctc.CategoryCheckTypeId
         WHERE pt.Code = 'C03'
               AND P.Active = 1
         ORDER BY Name;
     END;


GO