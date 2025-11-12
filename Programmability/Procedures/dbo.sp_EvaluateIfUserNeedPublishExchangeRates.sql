SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_EvaluateIfUserNeedPublishExchangeRates]                                                                                                    
                                                     @AgencyId  INT          = NULL,
													 @UserId    INT          = NULL
AS
     SET NOCOUNT ON;
     BEGIN
	 DECLARE @NumberAgencies INT;
	 --DECLARE @UserId  INT = 84;
	 --DECLARE @AgencyId  INT  = NULL;
	 IF(@AgencyId IS NOT NULL)--Cajero, para este solo se evalua que en la agencia que está logueado si haya publicado los exchange rate
	  BEGIN
		SELECT CASE WHEN @AgencyId IN(
			SELECT AgencyId FROM Agencies WHERE AgencyId NOT IN (select AgencyId from Agencies WHERE IsActive = 1 AND AgencyId IN (
				SELECT bera.AgencyId FROM PublishExchangeRates ber INNER JOIN PublishExchangeRatesByAgency bera 
					ON ber.PublishExchangeRateId = bera.PublishExchangeRateId )) AND IsActive = 1) AND (SELECT COUNT(*) FROM PublishExchangeRates ) > 0 
				THEN CAST(1 AS BIT) 
				ELSE CAST(0 AS BIT) END AS NeedPublish
	 END
	 ELSE--Admin y manager, para estos se debe validar si alguna de las agencias en que están registrados como cajeros, falta por publicar los exchange rates
	 BEGIN  
	 SELECT @NumberAgencies = count(*) FROM AgenciesxUser WHERE (UserId = @UserId OR @UserId IS NULL) AND AgencyId  IN(
			SELECT AgencyId FROM Agencies WHERE AgencyId NOT IN (select AgencyId from Agencies WHERE IsActive = 1 AND AgencyId IN (
				SELECT bera.AgencyId FROM PublishExchangeRates ber INNER JOIN PublishExchangeRatesByAgency bera 
					ON ber.PublishExchangeRateId = bera.PublishExchangeRateId )) AND IsActive = 1)
			SELECT CASE WHEN @NumberAgencies > 0  AND (SELECT COUNT(*) FROM PublishExchangeRates ) > 0 
				THEN CAST(1 AS BIT)
				ELSE CAST(0 AS BIT) END AS NeedPublish
			
	 END
  END;
GO