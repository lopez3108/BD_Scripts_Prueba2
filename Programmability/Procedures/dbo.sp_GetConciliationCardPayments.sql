SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationCardPayments] @AgencyId INT = NULL,
@BankAccountId INT = NULL,
@BankId INT = NULL,
@IsCredit BIT = NULL,
@DateTo DATETIME = NULL,
@DateFrom DATETIME = NULL
AS
BEGIN

  SELECT
    dbo.ConciliationCardPayments.ConciliationCardPaymentId
   ,dbo.ConciliationCardPayments.AgencyId
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyName
   ,dbo.ConciliationCardPayments.BankAccountId
   ,dbo.BankAccounts.AccountNumber
   ,dbo.Bank.BankId
   ,dbo.Bank.Name AS BankName
   ,dbo.ConciliationCardPayments.FromDate
   ,FORMAT(ConciliationCardPayments.FromDate, 'MM-dd-yyyy', 'en-US') FromDateFormat
   ,dbo.ConciliationCardPayments.ToDate
   ,FORMAT(ConciliationCardPayments.ToDate, 'MM-dd-yyyy ', 'en-US') ToDateFormat
   ,dbo.ConciliationCardPayments.IsCredit
   ,dbo.fn_GetConciliationCardPaymentTotal(dbo.ConciliationCardPayments.ConciliationCardPaymentId) AS Usd
   ,dbo.ConciliationCardPayments.CreatedBy
   ,dbo.Users.Name AS CreatedByName
   ,dbo.ConciliationCardPayments.CreationDate
   ,FORMAT(ConciliationCardPayments.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,CASE
      WHEN dbo.ConciliationCardPayments.IsCredit = 1 THEN ' CREDIT'
      ELSE ' DEBIT'
    END AS 'Type'
   ,CASE

      WHEN dbo.ConciliationCardPayments.IsCredit = 1 THEN ' DEBIT'
      ELSE ' CREDIT'
    END AS 'OperationType'
   ,ConciliationCardPayments.MidSaved
  FROM dbo.ConciliationCardPayments
  INNER JOIN dbo.BankAccounts
    ON dbo.ConciliationCardPayments.BankAccountId = dbo.BankAccounts.BankAccountId
  INNER JOIN dbo.Agencies
    ON dbo.ConciliationCardPayments.AgencyId = dbo.Agencies.AgencyId
  INNER JOIN dbo.Bank
    ON dbo.BankAccounts.BankId = dbo.Bank.BankId
  INNER JOIN dbo.Users
    ON dbo.Users.UserId = dbo.ConciliationCardPayments.CreatedBy
  WHERE dbo.ConciliationCardPayments.AgencyId = CASE
    WHEN @AgencyId IS NULL THEN dbo.ConciliationCardPayments.AgencyId
    ELSE @AgencyId
  END
  AND dbo.BankAccounts.BankAccountId = CASE
    WHEN @BankAccountId IS NULL THEN dbo.BankAccounts.BankAccountId
    ELSE @BankAccountId
  END
  AND dbo.Bank.BankId = CASE
    WHEN @BankId IS NULL THEN dbo.Bank.BankId
    ELSE @BankId
  END
  AND dbo.ConciliationCardPayments.IsCredit = CASE
    WHEN @IsCredit IS NULL THEN dbo.ConciliationCardPayments.IsCredit
    ELSE @IsCredit
  END
  AND CAST(dbo.ConciliationCardPayments.FromDate AS DATE) >= CASE
    WHEN @DateFrom IS NULL THEN CAST(dbo.ConciliationCardPayments.FromDate AS DATE)
    ELSE CAST(@DateFrom AS DATE)
  END
  AND CAST(dbo.ConciliationCardPayments.FromDate AS DATE) <= CASE
    WHEN @DateTo IS NULL THEN CAST(dbo.ConciliationCardPayments.FromDate AS DATE)
    ELSE CAST(@DateTo AS DATE)
  END
  ORDER BY dbo.ConciliationCardPayments.CreationDate DESC

END
GO