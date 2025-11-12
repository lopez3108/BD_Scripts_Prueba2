SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 16/09/2025  JF task 6688 Pagar menos de lo disponible cuando se hace Money distribution
-- 22/09/2025  JF task 6762 Resaltar número de cuenta

CREATE PROCEDURE [dbo].[sp_GetAllMoneyDistributionByCashier] @CashierId INT
AS
BEGIN

  SELECT
    dbo.Providers.ProviderId
   ,dbo.Agencies.AgencyId
   ,dbo.BankAccounts.BankAccountId
   ,dbo.MoneyDistribution.MoneyDistributionId
   ,dbo.MoneyDistribution.CashierId
   ,dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId
   ,dbo.MoneyDistribution.IsDefault
   ,ISNULL(dbo.Providers.LimitBalance, CAST(0 AS BIT)) AS LimitBalance
   ,dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId AS ProviderId
   ,dbo.Providers.Name + ' (' + (SELECT TOP 1
        mt.Number
      FROM dbo.MoneyDistribution m
      INNER JOIN dbo.MoneyTransferxAgencyNumbers mt
        ON m.MoneyTransferxAgencyNumbersId = mt.MoneyTransferxAgencyNumbersId
      WHERE m.MoneyDistributionId = dbo.MoneyDistribution.MoneyDistributionId)
    + ') ' +
    ' / ' + Agencies.Code + ' - ' + Agencies.Name AS ProviderName
   ,' (' + (SELECT TOP 1
        mt.Number
      FROM dbo.MoneyDistribution m
      INNER JOIN dbo.MoneyTransferxAgencyNumbers mt
        ON m.MoneyTransferxAgencyNumbersId = mt.MoneyTransferxAgencyNumbersId
      WHERE m.MoneyDistributionId = dbo.MoneyDistribution.MoneyDistributionId)
    + ') ' +
    ' / ' + Agencies.Code AS CodeProviderAgency
   ,dbo.MoneyDistribution.BankAccountId
   ,('**** ' + dbo.BankAccounts.AccountNumber ) AS BankAccountNameOnly
   ,('**** ' + dbo.BankAccounts.AccountNumber + ' ' + dbo.Bank.Name) AS BankAccountName
  FROM dbo.BankAccounts
  INNER JOIN dbo.Bank
    ON dbo.BankAccounts.BankId = dbo.Bank.BankId
  RIGHT OUTER JOIN dbo.MoneyDistribution
    ON dbo.BankAccounts.BankAccountId = dbo.MoneyDistribution.BankAccountId
  LEFT OUTER JOIN dbo.Providers
  INNER JOIN dbo.MoneyTransferxAgencyNumbers
    ON dbo.Providers.ProviderId = dbo.MoneyTransferxAgencyNumbers.ProviderId
  INNER JOIN dbo.Agencies
    ON dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.Agencies.AgencyId
    ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
  WHERE dbo.MoneyDistribution.CashierId = @CashierId
  ORDER BY dbo.MoneyDistribution.IsDefault DESC, LimitBalance DESC





END;

GO