SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationOthersDistribution] 
@ConciliationOtherId INT
AS
     BEGIN

SELECT        dbo.ConciliationOthersDistributions.ConciliationOthersDistributionId, dbo.ConciliationOthersDistributions.ConciliationOtherId, dbo.ConciliationOthersDistributions.AgencyId, dbo.ConciliationOthersDistributions.Usd, 
                         dbo.Agencies.Name, dbo.Agencies.Code
FROM            dbo.ConciliationOthersDistributions INNER JOIN
                         dbo.Agencies ON dbo.ConciliationOthersDistributions.AgencyId = dbo.Agencies.AgencyId
						 WHERE dbo.ConciliationOthersDistributions.ConciliationOtherId = @ConciliationOtherId

END
GO