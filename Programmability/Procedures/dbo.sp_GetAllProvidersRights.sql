SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersRights]
AS
     BEGIN
         SELECT p.ProviderId AS ID,
                UPPER(p.Name) AS Name,
                1 AS TypeId,
                UPPER(pt.Description) AS ProviderType
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         WHERE Active = 1
         UNION ALL
         SELECT [OtherId] AS ID,
                UPPER(Name) AS Name,
                2 AS TypeId,
                'OTHER' AS ProviderType
         FROM [dbo].[OthersServices]
         WHERE Active = 1
         ORDER BY Name;
     END;
GO