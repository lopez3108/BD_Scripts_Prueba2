SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-02-05 5652: DJ => SP used to check if a provider money transfer forex has pending commissions to be paid
CREATE PROCEDURE [dbo].[sp_GetMoneyTransferForexPendingCommissions] 
(
@ProviderId INT
)
AS
    BEGIN

SELECT 
fo.ForexId, 
DATEPART(YEAR,fo.FromDate) as [Year],
DATEPART(MONTH,fo.FromDate) as [Month],
CAST(DATEPART(YEAR,fo.FromDate) as VARCHAR(4)) + '-' + CAST(DATEPART(MONTH,fo.FromDate) as VARCHAR(2)) as YearMonth, 
fo.Usd 
FROM Forex fo
WHERE fo.ProviderId = @ProviderId AND fo.ForexId NOT IN (
    SELECT f.ForexId FROM Forex f
    INNER JOIN dbo.ProviderCommissionPayments pcp ON f.ProviderId = pcp.ProviderId 
	AND pcp.Year = DATEPART(YEAR, f.FromDate) AND pcp.Month = DATEPART(MONTH, f.FromDate)
	AND pcp.AgencyId = f.AgencyId AND pcp.IsForex = CAST(1 as BIT)
    WHERE f.ProviderId = @ProviderId)

       
    END;
GO