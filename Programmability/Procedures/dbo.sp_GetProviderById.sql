SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderById](@ProviderId INT)
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                p.Comision,
                p.ShowInBalance,
                pt.Description AS ProviderType,
                pt.Code AS ProviderTypeCode,
                CASE
                    WHEN p.CostAndCommission = 1
                    THEN 'true'
                    ELSE 'false'
                END AS CostAndCommission
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         WHERE P.ProviderId = @ProviderId;
     END;
GO