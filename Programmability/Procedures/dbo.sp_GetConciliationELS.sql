SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationELS] @AgencyId INT = NULL,
@BankAccountId INT = NULL,
@BankId INT = NULL,
@IsCredit BIT = NULL,
@DateTo DATETIME = NULL,
@DateFrom DATETIME = NULL
AS
BEGIN
  SELECT
    (SELECT TOP 1
        Description
      FROM dbo.ProviderTypes
      WHERE Code = 'C05')
    AS ProviderName
   ,dbo.ConciliationELS.ConciliationELSId
   ,dbo.ConciliationELS.AgencyId
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyName
   ,dbo.ConciliationELS.BankAccountId
   ,dbo.BankAccounts.AccountNumber
   ,dbo.Bank.BankId
   ,dbo.Bank.Name AS BankName
   ,dbo.ConciliationELS.FromDate
   ,FORMAT(ConciliationELS.FromDate, 'MM-dd-yyyy', 'en-US') FromDateFormat
   ,dbo.ConciliationELS.ToDate
   ,FORMAT(ConciliationELS.ToDate, 'MM-dd-yyyy ', 'en-US') ToDateFormat
   ,dbo.ConciliationELS.IsCredit
   ,dbo.ConciliationELS.IsDebit
   ,dbo.ConciliationELS.IsCommissionPayments
   ,dbo.fn_GetConciliationELSTotal(dbo.ConciliationELS.ConciliationELSId) AS Usd
   ,dbo.ConciliationELS.CreatedBy
   ,dbo.Users.Name AS CreatedByName
   ,dbo.ConciliationELS.CreationDate
   ,FORMAT(ConciliationELS.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,CASE
      WHEN dbo.ConciliationELS.IsCredit = 1 THEN ' CREDIT'
      WHEN dbo.ConciliationELS.IsDebit = 1 THEN ' DEBIT'
      WHEN dbo.ConciliationELS.IsCommissionPayments = 1 THEN ' COMMISSION PAYMENTS'
    END AS 'Type'
   ,CASE
      WHEN dbo.ConciliationELS.IsCredit = 1 THEN ' DEBIT'
      WHEN dbo.ConciliationELS.IsDebit = 1 THEN ' CREDIT'
      WHEN dbo.ConciliationELS.IsCommissionPayments = 1 THEN ' COMMISSION PAYMENTS'
    END AS 'OperationType'
  FROM dbo.ConciliationELS
  INNER JOIN dbo.BankAccounts
    ON dbo.ConciliationELS.BankAccountId = dbo.BankAccounts.BankAccountId
  INNER JOIN dbo.Agencies
    ON dbo.ConciliationELS.AgencyId = dbo.Agencies.AgencyId
  INNER JOIN dbo.Bank
    ON dbo.BankAccounts.BankId = dbo.Bank.BankId
  INNER JOIN dbo.Users
    ON dbo.Users.UserId = dbo.ConciliationELS.CreatedBy
  WHERE dbo.ConciliationELS.AgencyId = CASE
    WHEN @AgencyId IS NULL THEN dbo.ConciliationELS.AgencyId
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
  AND dbo.ConciliationELS.IsCredit = CASE
    WHEN @IsCredit IS NULL THEN dbo.ConciliationELS.IsCredit
    ELSE @IsCredit
  END
  AND CAST(dbo.ConciliationELS.FromDate AS DATE) >= CASE
    WHEN @DateFrom IS NULL THEN CAST(dbo.ConciliationELS.FromDate AS DATE)
    ELSE CAST(@DateFrom AS DATE)
  END
  AND CAST(dbo.ConciliationELS.FromDate AS DATE) <= CASE
    WHEN @DateTo IS NULL THEN CAST(dbo.ConciliationELS.FromDate AS DATE)
    ELSE CAST(@DateTo AS DATE)
  END
  ORDER BY dbo.ConciliationELS.CreationDate DESC;
END;
GO