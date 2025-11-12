SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetConciliationCardPayment] 
@AgencyId INT = NULL,
@BankAccountId INT = NULL,
@BankId INT = NULL,
@IsCredit BIT = NULL,
@DateTo DATETIME = NULL,
@DateFrom DATETIME = NULL
AS
     BEGIN

SELECT        
dbo.ConciliationCardPayment.ConciliationCardPaymentId,  
dbo.ConciliationCardPayment.AgencyId, 
dbo.Agencies.Code + ' - ' + dbo.Agencies.Name as AgencyName, 
dbo.ConciliationCardPayment.BankAccountId, 
dbo.BankAccounts.AccountNumber, 
dbo.Bank.BankId, 
dbo.Bank.Name AS BankName, 
dbo.ConciliationCardPayment.FromDate, 
dbo.ConciliationCardPayment.ToDate, 
dbo.ConciliationCardPayment.IsCredit, 
dbo.fn_GetConciliationCardPaymentTotal(dbo.ConciliationCardPayment.ConciliationCardPaymentId) as Usd, 
dbo.ConciliationCardPayment.CreatedBy, 
dbo.Users.Name AS CreatedByName, 
dbo.ConciliationCardPayment.CreationDate,
CASE 
WHEN dbo.ConciliationCardPayment.IsCredit = 1 THEN
'+ CREDIT' ELSE
'- DEBIT' END AS 'Type'

FROM            dbo.ConciliationCardPayment INNER JOIN
                         dbo.BankAccounts ON dbo.ConciliationCardPayment.BankAccountId = dbo.BankAccounts.BankAccountId INNER JOIN
                         dbo.Agencies ON dbo.ConciliationCardPayment.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId INNER JOIN
                         dbo.Users ON dbo.Users.UserId = dbo.ConciliationCardPayment.CreatedBy
						 WHERE 
						 dbo.ConciliationCardPayment.AgencyId = CASE
						 WHEN @AgencyId IS NULL THEN
						 dbo.ConciliationCardPayment.AgencyId ELSE
						 @AgencyId END AND
						 dbo.BankAccounts.BankAccountId = CASE
						 WHEN @BankAccountId IS NULL THEN
						 dbo.BankAccounts.BankAccountId ELSE
						 @BankAccountId END AND
						 dbo.Bank.BankId = CASE
						 WHEN @BankId IS NULL THEN
						 dbo.Bank.BankId ELSE
						 @BankId END AND
						 dbo.ConciliationCardPayment.IsCredit = CASE
						 WHEN @IsCredit IS NULL THEN
						 dbo.ConciliationCardPayment.IsCredit ELSE
						 @IsCredit END AND
						  CAST(dbo.ConciliationCardPayment.CreationDate AS DATE) = CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.ConciliationCardPayment.CreationDate AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.ConciliationCardPayment.CreationDate AS DATE) = CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.ConciliationCardPayment.CreationDate AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END
															 ORDER BY dbo.ConciliationCardPayment.CreationDate DESC

END



GO