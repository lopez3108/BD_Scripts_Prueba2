SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersByProviderTypeCode] @ProviderTypeCode NVARCHAR(1000)
AS
     BEGIN
         --SELECT p.ProviderId,
         --       p.Name,
         --       p.Active,
         --       p.ProviderTypeId,
         --       p.AcceptNegative,
         --       p.Comision,
         --       pt.Code AS ProviderTypeCode,
         --       pt.Description AS ProviderType
         --FROM Providers p
         --     INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         --WHERE pt.Code IN
         --(
         --    SELECT item
         --    FROM dbo.FN_ListToTableInt(@ProviderTypeCode)
         --)
         --     AND P.Active = 1
         --ORDER BY Name;


         DECLARE @query AS NVARCHAR(MAX);
         SET @query = '
   SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
			 p.LimitBalance,
                p.Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId  WHERE pt.Code IN('+@ProviderTypeCode+')    AND P.Active = 1
         ORDER BY Name;';
         EXECUTE sp_executesql
                 @query;
     END;

GO