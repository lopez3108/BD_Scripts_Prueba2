SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentBanksToBanks] 
@FromBankAccountId INT = NULL,
@ToBankAccountId INT = NULL,
@BankId      INT = NULL,
@DateFrom        DATETIME = NULL,
@DateTo       DATETIME = NULL
AS
BEGIN


SELECT        
dbo.PaymentBanksToBanks.PaymentBanksToBankId, 
dbo.PaymentBanksToBanks.FromBankAccountId as FromBankAccountId, 
fromb.BankId as FromBankId, 
fromb.AccountNumber as FromAccountNumber, 
fromba.Name as FromBankName, 
dbo.PaymentBanksToBanks.ToBankAccountId, 
tob.AccountNumber AS ToAccountNumber, 
tob.BankId AS ToBankId, 
toba.Name AS ToBankName, 
dbo.PaymentBanksToBanks.CreatedBy, 
UPPER(dbo.Users.Name) AS CreatedByName,
dbo.PaymentBanksToBanks.USD as Usd,
dbo.PaymentBanksToBanks.Date,
FORMAT(PaymentBanksToBanks.Date, 'MM-dd-yyyy', 'en-US')  DateToBanksFormat,
dbo.PaymentBanksToBanks.CreationDate,
FORMAT(PaymentBanksToBanks.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat
FROM            dbo.BankAccounts fromb INNER JOIN
                         dbo.PaymentBanksToBanks ON fromb.BankAccountId = dbo.PaymentBanksToBanks.FromBankAccountId INNER JOIN
                         dbo.Bank fromba ON fromb.BankId = fromba.BankId INNER JOIN
                         dbo.BankAccounts AS tob ON dbo.PaymentBanksToBanks.ToBankAccountId = tob.BankAccountId INNER JOIN
                         dbo.Bank AS toba ON tob.BankId = toba.BankId INNER JOIN
                         dbo.Users ON dbo.PaymentBanksToBanks.CreatedBy = dbo.Users.UserId
						 WHERE 
						 (fromb.BankId = CASE
						 WHEN @BankId IS NULL THEN
						 fromb.BankId ELSE
						 @BankId END OR 
						 tob.BankId = CASE
						 WHEN @BankId IS NULL THEN
						 tob.BankId ELSE
						 @BankId END )AND
						  fromb.BankAccountId = CASE
						  WHEN @FromBankAccountId IS NULL THEN
						   fromb.BankAccountId ELSE
						   @FromBankAccountId  END AND
						  tob.BankAccountId = CASE
						  WHEN @ToBankAccountId IS NULL THEN
						   tob.BankAccountId ELSE
						   @ToBankAccountId  END AND
						   CAST(dbo.PaymentBanksToBanks.Date AS DATE) >= CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.PaymentBanksToBanks.Date AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.PaymentBanksToBanks.Date AS DATE) <= CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.PaymentBanksToBanks.Date AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END
															 ORDER BY dbo.PaymentBanksToBanks.Date DESC










END
GO