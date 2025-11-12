SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAgenciesResume]
 
 @Date datetime
AS 

BEGIN

SELECT  
Agencies.Name, 
dbo.fn_GetAgencyCheckNumberCashed(Agencies.AgencyId, @Date) as ChecksCashed,  
dbo.fn_GetAgencyCheckAmountCashed(Agencies.AgencyId, @Date) as AmountCashed,  
dbo.fn_GetAgencyCheckNumberBounced(Agencies.AgencyId, @Date) as ChecksBounced,  
dbo.fn_GetAgencyCheckAmountBounced(Agencies.AgencyId, @Date) as AmountBounced,  
dbo.fn_GetAgencyChecEarnings(Agencies.AgencyId, @Date) as Earnings
FROM            Agencies

	
	END

GO