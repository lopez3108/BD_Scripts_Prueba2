SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentBanks] @BankAccountId INT      = NULL, 
                                           @BankId        INT      = NULL, 
                                           @DateFrom      DATETIME = NULL, 
                                           @DateTo        DATETIME = NULL, 
                                           @Status        INT      = NULL
AS
    BEGIN
        SELECT dbo.PaymentBanks.PaymentBankId, 
               dbo.PaymentBanks.BankAccountId, 
               ISNULL(dbo.BankAccounts.AccountNumber, '') AccountNumber, 
               dbo.BankAccounts.BankId, 
               dbo.Bank.Name AS BankName, 
               dbo.PaymentBanks.Date, 
			   FORMAT(PaymentBanks.Date, 'MM-dd-yyyy', 'en-US')  DateBanksFormat,
               dbo.PaymentBanks.CreationDate, 
			   FORMAT(PaymentBanks.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PaymentBanks.CreatedBy, 
               UPPER(dbo.Users.Name) AS CreatedByName, 
               dbo.PaymentBanks.USD AS Usd,
               CASE
                   WHEN dbo.PaymentBanks.STATUS = '1'
                   THEN 'PENDING'
                   WHEN dbo.PaymentBanks.STATUS = '2'
                   THEN 'COMPLETE'
                   WHEN dbo.PaymentBanks.STATUS = '3'
                   THEN 'DELETED'
               END AS Status,
			    CASE
                   WHEN dbo.PaymentBanks.STATUS = '1'
                   THEN 'PENDING'
                   WHEN dbo.PaymentBanks.STATUS = '2'
                   THEN 'COMPLETED'
                   WHEN dbo.PaymentBanks.STATUS = '3'
                   THEN 'DELETED'
               END AS StatusName, 
               dbo.PaymentBanks.FileImageName, 
               UPPER(a.Code + ' - ' + a.Name) AgencyName
        FROM dbo.PaymentBanks
             LEFT JOIN dbo.BankAccounts ON dbo.PaymentBanks.BankAccountId = dbo.BankAccounts.BankAccountId
             LEFT JOIN dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId
             INNER JOIN dbo.Users ON dbo.PaymentBanks.CreatedBy = dbo.Users.UserId
             LEFT JOIN Agencies a ON PaymentBanks.AgencyId = a.AgencyId
        WHERE(dbo.BankAccounts.BankId = @BankId
              OR @BankId IS NULL
              OR dbo.BankAccounts.BankId IS NULL)
             AND (dbo.PaymentBanks.STATUS = @Status
                  OR @Status IS NULL)
             AND (dbo.BankAccounts.BankAccountId = @BankAccountId
                  OR @BankAccountId IS NULL
                  OR dbo.BankAccounts.BankAccountId IS NULL)
             AND ((CAST(dbo.PaymentBanks.Date AS DATE) >= CAST(@DateFrom AS DATE)
                   OR @DateFrom IS NULL)
                  AND (CAST(dbo.PaymentBanks.Date AS DATE) <= CAST(@DateTo AS DATE)
                       OR @DateTo IS NULL))
        ORDER BY dbo.PaymentBanks.Date DESC;
    END;
GO