SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPaymentAdjustment] @AgencyFromId INT,
@AgencyToId INT = null,
@DateFrom DATETIME,
@DateTo DATETIME 

AS
BEGIN


SELECT
	dbo.PaymentAdjustment.PaymentAdjustmentId
   ,dbo.Agencies.AgencyId AS AgencyToId
   ,dbo.Agencies.Name AS AgencyFromName
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyFromCodeName
   ,'+ CREDIT'  AS TypeFrom
   ,Agencies_1.AgencyId AS AgencyToId
   ,Agencies_1.Name AS AgencyToName
   ,Agencies_1.Code + ' - ' + Agencies_1.Name AS AgencyToCodeName
   ,dbo.Providers.ProviderId
   ,dbo.Providers.Name +
	ISNULL((SELECT TOP 1
			' - ' + dbo.MoneyTransferxAgencyNumbers.number
		FROM dbo.MoneyTransferxAgencyNumbers
		WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentAdjustment.AgencyFromId
		AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentAdjustment.ProviderId)
	, '') AS ProviderFromName
   ,dbo.Providers.Name +
	ISNULL((SELECT TOP 1
			' - ' + dbo.MoneyTransferxAgencyNumbers.number
		FROM dbo.MoneyTransferxAgencyNumbers
		WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentAdjustment.AgencyToId
		AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentAdjustment.ProviderId)
	, '') AS ProviderToName
   ,dbo.PaymentAdjustment.USD
   ,dbo.PaymentAdjustment.CreationDate
   ,FORMAT(PaymentAdjustment.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat
   ,dbo.PaymentAdjustment.DeletedOn
   ,FORMAT(PaymentAdjustment.DeletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DeletedOnFormat
   ,UPPER(dbo.Users.Name) AS DeletedBy
   ,CASE
		WHEN dbo.PaymentAdjustment.DeletedOn IS NOT NULL THEN 'DELETED'
		ELSE 'ACTIVE'
	END AS Status
   ,dbo.PaymentAdjustment.DATE
   , FORMAT(PaymentAdjustment.DATE, 'MM-dd-yyyy', 'en-US')  DateAdjustmentFormat
   ,UPPER(Users1.Name) AS CreatedByName
FROM dbo.PaymentAdjustment
INNER JOIN dbo.Providers
	ON dbo.PaymentAdjustment.ProviderId = dbo.Providers.ProviderId
INNER JOIN dbo.Agencies
	ON dbo.PaymentAdjustment.AgencyFromId = dbo.Agencies.AgencyId
INNER JOIN dbo.Agencies AS Agencies_1
	ON dbo.PaymentAdjustment.AgencyToId = Agencies_1.AgencyId
LEFT OUTER JOIN dbo.Users
	ON dbo.PaymentAdjustment.DeletedBy = dbo.Users.UserId
INNER JOIN dbo.Users AS Users1
	ON dbo.PaymentAdjustment.CreatedBy = Users1.UserId
WHERE dbo.PaymentAdjustment.AgencyFromId = @AgencyFromId
AND CAST(dbo.PaymentAdjustment.Date AS DATE) >= CAST(@DateFrom AS DATE)
AND CAST(dbo.PaymentAdjustment.Date AS DATE) <= CAST(@DateTo AS DATE)
AND ((dbo.PaymentAdjustment.AgencyToId = @AgencyToId)
OR @AgencyToId IS NULL)




END;
GO