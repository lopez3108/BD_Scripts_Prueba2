SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBillPaymentsTotal]
AS
     BEGIN

SELECT        dbo.Providers.ProviderId, dbo.Providers.Name, dbo.Providers.CostAndCommission, dbo.ProviderTypes.Code
FROM            dbo.Providers INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE CostAndCommission	= 0 AND
Code = 'C01' AND
Active = 1
		
		
		 END
GO