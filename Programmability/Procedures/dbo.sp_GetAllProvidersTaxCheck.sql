SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersTaxCheck]
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name,
			 p.ProviderTypeId,
			 p.AcceptNegative,
			 p.Comision, 
			 pt.Code AS ProviderTypeCode,
			 pt.Description AS ProviderType,			 
			 CT.MaxCheckAmount,
			 CT.Description DescriptionCheckType 
         FROM Providers p INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
		     LEFT JOIN CheckTypesCategories ctc ON ctc.Code = 'C03' LEFT JOIN CheckTypes CT ON CT.CategoryCheckTypeId = ctc.CategoryCheckTypeId
       	      WHERE pt.Code = 'C04'
			 ORDER BY Name;
     END;


GO