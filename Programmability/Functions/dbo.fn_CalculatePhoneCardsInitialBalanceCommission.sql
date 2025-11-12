SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculatePhoneCardsInitialBalanceCommission](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN (


	ISNULL((SELECT
SUM((ISNULL(dbo.PhoneCards.PhoneCardsUsd, 0) * ISNULL(dbo.PhoneCards.Commission, 0) / 100))  AS Commission
        FROM  dbo.PhoneCards
						 WHERE 
						 dbo.PhoneCards.AgencyId = @AgencyId 
						AND CAST(dbo.PhoneCards.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0)

						-

						ISNULL((SELECT        

SUM(ISNULL(Usd,0))
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C23' AND
						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
						AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0)
  


)

END
GO