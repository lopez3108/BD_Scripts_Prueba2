SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentChecksAgenttoagent]

@AgencyFromId INT,
@AgencyToId INT,
@LotNumber INT =null,
@DateFrom DATETIME,
@DateTo DATETIME

AS
BEGIN


SELECT dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId,
		PaymentChecksAgentToAgent.CreationDate,
		dbo.Agencies.Name as FromAgency, 
		dbo.Agencies.Code + ' - ' +  dbo.Agencies.Name AS FromAgencyCodeName, 
		Agencies_1.Name as ToAgency,
		Agencies_1.Code + ' - ' +  Agencies_1.Name AS ToAgencyCodeName, 
		PaymentChecksAgentToAgent.Date as [Date],
		PaymentChecksAgentToAgent.Usd,
		PaymentChecksAgentToAgent.NumberChecks,
		CASE WHEN dbo.PaymentChecksAgentToAgent.DeletedOn IS NOT NULL THEN 'DELETED' ELSE 'ACTIVE' END AS [Status],
		UPPER(Users1.Name) as CreatedBy,
		PaymentChecksAgentToAgent.DeletedOn,
		UPPER(Users.Name) as DeletedBy,
		PaymentChecksAgentToAgent.FromDate,
		PaymentChecksAgentToAgent.ToDate,
		Fee,
  pr.Name + ISNULL((SELECT  TOP 1  CASE
WHEN pt.Code = 'C02' THEN
 ' - ' + ISNULL(mn.Number, 'NOT REGISTERED') ELSE
 '' END
FROM           
                        
                         dbo.MoneyTransferxAgencyNumbers mn
						 WHERE 
						 mn.ProviderId = pr.ProviderId AND 
						 mn.AGencyId = dbo.PaymentChecksAgentToAgent.ToAgency),'') as ProviderName
						 
FROM dbo.PaymentChecksAgentToAgent 
		INNER JOIN dbo.Agencies ON dbo.PaymentChecksAgentToAgent.FromAgency = dbo.Agencies.AgencyId 
		INNER JOIN dbo.Agencies AS Agencies_1 ON dbo.PaymentChecksAgentToAgent.ToAgency = Agencies_1.AgencyId 
		LEFT OUTER JOIN dbo.Users ON dbo.PaymentChecksAgentToAgent.DeletedBy = dbo.Users.UserId 
		INNER JOIN dbo.Users as Users1 ON dbo.PaymentChecksAgentToAgent.CreatedBy = Users1.UserId 
		INNER JOIN dbo.Providers pr ON pr.ProviderId = dbo.PaymentChecksAgentToAgent.ProviderId
		INNER JOIN dbo.ProviderTypes pt ON pt.ProviderTypeId = pr.ProviderTypeId
WHERE dbo.PaymentChecksAgentToAgent.FromAgency = @AgencyFromId AND
		dbo.PaymentChecksAgentToAgent.ToAgency = @AgencyToId AND
		CAST(dbo.PaymentChecksAgentToAgent.CreationDate AS DATE) >= CAST(@DateFrom AS DATE) AND
		CAST(dbo.PaymentChecksAgentToAgent.CreationDate AS DATE) <= CAST(@DateTo AS DATE) 
		AND (PaymentChecksAgentToAgent.LotNumber = @LotNumber or @LotNumber is null) 
     END;
GO