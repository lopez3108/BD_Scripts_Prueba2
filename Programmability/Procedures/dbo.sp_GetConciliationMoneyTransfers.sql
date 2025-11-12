SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetConciliationMoneyTransfers] 
@ProviderId INT = NULL,
@AgencyId INT = NULL,
@BankAccountId INT = NULL,
@BankId INT = NULL,
@IsCredit BIT = NULL,
@DateTo DATETIME = NULL,
@DateFrom DATETIME = NULL
AS
     BEGIN

SELECT        
dbo.ConciliationMoneyTransfers.ConciliationMoneyTransfersId, 
dbo.ConciliationMoneyTransfers.ProviderId, 
dbo.Providers.Name as ProviderName, 
dbo.ConciliationMoneyTransfers.AgencyId, 
dbo.Agencies.Code + ' - ' + dbo.Agencies.Name as AgencyName, 
dbo.ConciliationMoneyTransfers.BankAccountId, 
dbo.BankAccounts.AccountNumber, 
dbo.Bank.BankId, 
dbo.Bank.Name AS BankName, 
dbo.ConciliationMoneyTransfers.Date, 
FORMAT(ConciliationMoneyTransfers.Date, 'MM-dd-yyyy ', 'en-US') DateFormat ,
dbo.ConciliationMoneyTransfers.IsCredit, 
dbo.ConciliationMoneyTransfers.Usd, 
dbo.ConciliationMoneyTransfers.CreatedBy, 
dbo.Users.Name AS CreatedByName, 
dbo.ConciliationMoneyTransfers.CreationDate,
FORMAT(ConciliationMoneyTransfers.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat ,
CASE 
WHEN dbo.ConciliationMoneyTransfers.IsCredit = 1 THEN
' CREDIT' ELSE
' DEBIT' END AS 'Type',

CASE 
WHEN dbo.ConciliationMoneyTransfers.IsCredit = 1 THEN
' DEBIT' ELSE
' CREDIT' END AS 'OperationType'

FROM            dbo.ConciliationMoneyTransfers INNER JOIN
                         dbo.BankAccounts ON dbo.ConciliationMoneyTransfers.BankAccountId = dbo.BankAccounts.BankAccountId INNER JOIN
                         dbo.Agencies ON dbo.ConciliationMoneyTransfers.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON dbo.ConciliationMoneyTransfers.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId INNER JOIN
                         dbo.Users ON dbo.Users.UserId = dbo.ConciliationMoneyTransfers.CreatedBy
						 WHERE 
						 dbo.ConciliationMoneyTransfers.AgencyId = CASE
						 WHEN @AgencyId IS NULL THEN
						 dbo.ConciliationMoneyTransfers.AgencyId ELSE
						 @AgencyId END AND
						 dbo.BankAccounts.BankAccountId = CASE
						 WHEN @BankAccountId IS NULL THEN
						 dbo.BankAccounts.BankAccountId ELSE
						 @BankAccountId END AND
						 dbo.Bank.BankId = CASE
						 WHEN @BankId IS NULL THEN
						 dbo.Bank.BankId ELSE
						 @BankId END AND
						 dbo.ConciliationMoneyTransfers.ProviderId = CASE
						 WHEN @ProviderId IS NULL THEN
						 dbo.ConciliationMoneyTransfers.ProviderId ELSE
						 @ProviderId END AND
						 dbo.ConciliationMoneyTransfers.IsCredit = CASE
						 WHEN @IsCredit IS NULL THEN
						 dbo.ConciliationMoneyTransfers.IsCredit ELSE
						 @IsCredit END AND
						  CAST(dbo.ConciliationMoneyTransfers.CreationDate AS DATE) >= CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.ConciliationMoneyTransfers.CreationDate AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.ConciliationMoneyTransfers.CreationDate AS DATE) <= CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.ConciliationMoneyTransfers.CreationDate AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END
															 ORDER BY dbo.ConciliationMoneyTransfers.CreationDate DESC

END


GO