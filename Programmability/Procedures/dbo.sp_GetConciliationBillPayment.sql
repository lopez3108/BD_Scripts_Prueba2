SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetConciliationBillPayment] 
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
dbo.ConciliationBillPayments.ConciliationBillPaymentId, 
dbo.ConciliationBillPayments.ProviderId, 
dbo.Providers.Name as ProviderName, 
dbo.ConciliationBillPayments.AgencyId, 
dbo.Agencies.Code + ' - ' + dbo.Agencies.Name as AgencyName, 
dbo.ConciliationBillPayments.BankAccountId, 
dbo.BankAccounts.AccountNumber, 
dbo.Bank.BankId, 
dbo.Bank.Name AS BankName, 
dbo.ConciliationBillPayments.Date, 
FORMAT(ConciliationBillPayments.Date, 'MM-dd-yyyy', 'en-US')  DateBillPaymentsFormat,
dbo.ConciliationBillPayments.IsCredit, 
dbo.ConciliationBillPayments.Usd, 
dbo.ConciliationBillPayments.CreatedBy, 
dbo.Users.Name AS CreatedByName, 
dbo.ConciliationBillPayments.CreationDate,
FORMAT(ConciliationBillPayments.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat ,
CASE 
WHEN dbo.ConciliationBillPayments.IsCredit = 1 THEN
' CREDIT' ELSE
' DEBIT' END AS 'Type',

CASE
WHEN dbo.ConciliationBillPayments.IsCredit = 1 THEN
' DEBIT' ELSE
' CREDIT' END AS 'OperationType'



FROM            dbo.ConciliationBillPayments INNER JOIN
                         dbo.BankAccounts ON dbo.ConciliationBillPayments.BankAccountId = dbo.BankAccounts.BankAccountId INNER JOIN
                         dbo.Agencies ON dbo.ConciliationBillPayments.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON dbo.ConciliationBillPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId INNER JOIN
                         dbo.Users ON dbo.Users.UserId = dbo.ConciliationBillPayments.CreatedBy
						 WHERE 
						 dbo.ConciliationBillPayments.AgencyId = CASE
						 WHEN @AgencyId IS NULL THEN
						 dbo.ConciliationBillPayments.AgencyId ELSE
						 @AgencyId END AND
						 dbo.BankAccounts.BankAccountId = CASE
						 WHEN @BankAccountId IS NULL THEN
						 dbo.BankAccounts.BankAccountId ELSE
						 @BankAccountId END AND
						 dbo.Bank.BankId = CASE
						 WHEN @BankId IS NULL THEN
						 dbo.Bank.BankId ELSE
						 @BankId END AND
						 dbo.ConciliationBillPayments.ProviderId = CASE
						 WHEN @ProviderId IS NULL THEN
						 dbo.ConciliationBillPayments.ProviderId ELSE
						 @ProviderId END AND
						 dbo.ConciliationBillPayments.IsCredit = CASE
						 WHEN @IsCredit IS NULL THEN
						 dbo.ConciliationBillPayments.IsCredit ELSE
						 @IsCredit END AND
						  CAST(dbo.ConciliationBillPayments.CreationDate AS DATE) >= CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.ConciliationBillPayments.CreationDate AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.ConciliationBillPayments.CreationDate AS DATE) <= CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.ConciliationBillPayments.CreationDate AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END
															 ORDER BY dbo.ConciliationBillPayments.CreationDate DESC

END


GO