SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetpaymentsBalanceManualProviders]
AS
    BEGIN
       
	   
	   SELECT dbo.Providers.ProviderId, 
                                      dbo.Providers.Name

                               FROM dbo.Providers
                                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                               WHERE (dbo.ProviderTypes.Code = 'C01') AND ( dbo.Providers.Active=1)
                               ORDER BY Name;
    END;
GO