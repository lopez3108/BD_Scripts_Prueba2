SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-19 DJ/5731: Created to add initial balance to report

CREATE FUNCTION [dbo].[FN_GetTopUpPaymentsTotalCommissionReport](
@AgencyId   INT, 
 @ProviderId INT, 
 @FromDate   DATETIME = NULL, 
 @ToDate     DATETIME = NULL)
RETURNS @result TABLE
( OperationTypeId INT
   ,ProviderCommissionPaymentId INT
   ,ProviderId INT
   ,CreationDate DATETIME
   ,[Type] VARCHAR(100)
   ,[Description] VARCHAR(100)
   ,[Month] INT
   ,[Year] INT
   ,[Debit] DECIMAL(18, 2) NULL
   ,[Credit] DECIMAL(18, 2) NULL
   ,[Balance] DECIMAL(18, 2) NULL
		 
)
AS
     BEGIN

				 INSERT INTO @result
                SELECT
      1 AS OperationTypeId
     ,dbo.ProviderCommissionPayments.ProviderCommissionPaymentId
     ,dbo.ProviderCommissionPayments.ProviderId
     ,CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) AS CreationDate
     ,'COMMISSION'
     ,'CLOSING COMISSION ' + UPPER(DATENAME(MONTH, DATEADD(MONTH, dbo.ProviderCommissionPayments.Month, 0) - 1)) + ' ' + CAST(dbo.ProviderCommissionPayments.Year AS VARCHAR(20))
     ,dbo.ProviderCommissionPayments.Month
     ,dbo.ProviderCommissionPayments.Year
     ,dbo.ProviderCommissionPayments.Usd
     ,NULL
     ,0 + dbo.ProviderCommissionPayments.Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.ProviderCommissionPaymentTypes
      ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
     AND CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    UNION ALL
    SELECT
      2 AS OperationTypeId
     ,dbo.ProviderCommissionPayments.ProviderCommissionPaymentId
     ,dbo.ProviderCommissionPayments.ProviderId
     ,CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) AS CreationDate
     ,'PAYMENT'
     ,'CLOSING COMISSION (' + dbo.ProviderCommissionPaymentTypes.[Description] +
	 CASE 
	 WHEN dbo.ProviderCommissionPayments.CheckNumber IS NOT NULL THEN
	 '# ' + dbo.ProviderCommissionPayments.CheckNumber + ')'
	 WHEN dbo.ProviderCommissionPayments.AchDate IS NOT NULL THEN
	 ' ' + CONVERT(VARCHAR(10), cast(dbo.ProviderCommissionPayments.AchDate as DATE), 101) + ' ' + '**** ' + b.AccountNumber + ' (' + ba.[Name] + '))'
	 ELSE ')' 
	 END as [Description]
     ,dbo.ProviderCommissionPayments.Month
     ,dbo.ProviderCommissionPayments.Year
     ,NULL
     ,dbo.ProviderCommissionPayments.Usd
     ,0 - dbo.ProviderCommissionPayments.Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.ProviderCommissionPaymentTypes
      ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
	  LEFT JOIN dbo.BankAccounts b ON b.BankAccountId = dbo.ProviderCommissionPayments.BankAccountId
	  LEFT JOIN dbo.Bank ba ON ba.BankId = b.BankId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    ORDER BY CAST(dbo.[fn_GetNextDayPeriod](dbo.ProviderCommissionPayments.[Year], dbo.ProviderCommissionPayments.[Month]) as DATE) ASC, ProviderCommissionPaymentId ASC, OperationTypeId ASC






         RETURN;
     END;





GO