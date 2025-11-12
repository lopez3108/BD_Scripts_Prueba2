SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentChecks]
@PaymentCheckId INT = NULL ,
@AgencyId INT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@ProviderId INT = NULL

AS
     BEGIN


SELECT dbo.PaymentChecks.PaymentCheckId,
		PaymentChecks.CreationDate,
		PaymentChecks.ProviderId,
		dbo.Agencies.AgencyId ToAgencyId,
		dbo.Agencies.Name as FromAgency, 
		dbo.Agencies.Code + ' - ' +  dbo.Agencies.Name AS AgencyCodeName, 
		PaymentChecks.Date as [Date],
		PaymentChecks.Usd,
		PaymentChecks.NumberChecks,
		CASE WHEN dbo.PaymentChecks.DeletedOn IS NOT NULL THEN 'DELETED' ELSE 'ACTIVE' END AS [Status],
		UPPER(Users1.Name) as CreatedByName,
		CreatedBy CreatedById,
		PaymentChecks.DeletedOn,
		UPPER(Users.Name) as DeletedBy,
		PaymentChecks.FromDate,
		PaymentChecks.ToDate,
		 Fee,
		 LotNumber,
  pr.Name + ISNULL((SELECT  TOP 1  CASE
WHEN pt.Code = 'C02' THEN
 ' - ' + ISNULL(mn.Number, 'NOT REGISTERED') ELSE
 '' END
FROM           
                        
                         dbo.MoneyTransferxAgencyNumbers mn
						 WHERE 
						 mn.ProviderId = pr.ProviderId AND 
						 mn.AGencyId = dbo.PaymentChecks.AgencyId),'') as ProviderName
						 
FROM dbo.PaymentChecks 
		INNER JOIN dbo.Agencies ON dbo.PaymentChecks.AgencyId = dbo.Agencies.AgencyId 
		LEFT OUTER JOIN dbo.Users ON dbo.PaymentChecks.DeletedBy = dbo.Users.UserId 
		INNER JOIN dbo.Users as Users1 ON dbo.PaymentChecks.CreatedBy = Users1.UserId 
		INNER JOIN dbo.Providers pr ON pr.ProviderId = dbo.PaymentChecks.ProviderId
		INNER JOIN dbo.ProviderTypes pt ON pt.ProviderTypeId = pr.ProviderTypeId
WHERE (dbo.PaymentChecks.AgencyId = @AgencyId OR @AgencyId IS NULL ) AND
(@ProviderId IS NULL OR pr.ProviderId = @ProviderId) AND
		(CAST(dbo.PaymentChecks.CreationDate AS DATE) >= CAST(@DateFrom AS DATE )OR @DateFrom IS NULL) AND
		(CAST(dbo.PaymentChecks.CreationDate AS DATE) <= CAST(@DateTo AS DATE) OR @DateTo IS NULL)  AND
		(@PaymentCheckId IS NULL OR PaymentChecks.PaymentCheckId = @PaymentCheckId) 





     END;
GO