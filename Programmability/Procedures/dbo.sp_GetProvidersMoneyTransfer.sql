SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProvidersMoneyTransfer] @Active BIT = NULL
AS
    BEGIN

SELECT        
dbo.Providers.ProviderId, 
dbo.Providers.Name, 
dbo.ProviderTypes.Code
FROM            dbo.Providers INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE dbo.ProviderTypes.Code = 'C02' AND
						 (dbo.Providers.Active = @Active OR @Active IS NULL)

       
    END;
GO