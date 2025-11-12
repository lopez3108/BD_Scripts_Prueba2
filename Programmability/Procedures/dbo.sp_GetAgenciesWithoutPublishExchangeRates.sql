SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAgenciesWithoutPublishExchangeRates]   
 @UserId    INT          = NULL
AS
     SET NOCOUNT ON;
     BEGIN
	 --DECLARE  @UserId    INT          = 84;
SELECT DISTINCT A.AgencyId, A.Name,A.Code + ' - ' +  A.Name CodeName FROM AgenciesxUser au INNER JOIN Agencies a ON a.AgencyId = au.AgencyId WHERE (UserId = @UserId OR @UserId IS NULL) AND A.AgencyId NOT IN
	(SELECT ag.AgencyId from Agencies ag WHERE ag.IsActive = 1 AND ag.AgencyId IN (
	SELECT bera.AgencyId FROM PublishExchangeRates ber INNER JOIN PublishExchangeRatesByAgency bera 
	ON ber.PublishExchangeRateId = bera.PublishExchangeRateId )
	) AND A.IsActive = 1
  END;
GO