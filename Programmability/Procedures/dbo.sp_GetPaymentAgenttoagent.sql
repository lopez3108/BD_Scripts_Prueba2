SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentAgenttoagent] @AgencyFromId INT, 
                                                  @AgencyToId   INT, 
                                                  @DateFrom     DATETIME, 
                                                  @DateTo       DATETIME
AS
    BEGIN
        SELECT dbo.PaymentOthersAgentToAgent.PaymentOthersAgentToAgentId, 
               dbo.PaymentOthersAgentToAgent.CreationDate, 
			   FORMAT(PaymentOthersAgentToAgent.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.Agencies.Name AS FromAgency, 
               dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS FromAgencyCodeName, 
               Agencies_1.Name AS ToAgency, 
               Agencies_1.Code + ' - ' + Agencies_1.Name AS ToAgencyCodeName, 
               dbo.PaymentOthersAgentToAgent.Date,
			   FORMAT(PaymentOthersAgentToAgent.Date, 'MM-dd-yyyy', 'en-US')  DateToAgentFormat,
               dbo.PaymentOthersAgentToAgent.Usd,
               CASE
                   WHEN dbo.PaymentOthersAgentToAgent.DeletedOn IS NOT NULL
                   THEN 'DELETED'
                   ELSE 'ACTIVE'
               END AS STATUS, 
               UPPER(Users1.Name) AS CreatedBy, 
               dbo.PaymentOthersAgentToAgent.CreationDate AS Expr1, 
               dbo.PaymentOthersAgentToAgent.DeletedOn, 
			   FORMAT(PaymentOthersAgentToAgent.DeletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DeletedOnFormat,
               UPPER(dbo.Users.Name) AS DeletedBy, 
               dbo.PaymentOthersAgentToAgent.Note, 
			   CAST(dbo.PaymentOthersAgentToAgent.Note as VARCHAR(30)) NoteInterface, 
               dbo.BankAccounts.AccountNumber,
			   dbo.BankAccounts.AccountNumber +  '-' +  dbo.CardBanks.CardNumber + ' ' +  '(' + dbo.Bank.Name + ')' as CardNumberr,
               dbo.CardBanks.CardNumber, 
               dbo.ProviderCommissionPaymentTypes.Code, 
               dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeName, 
               dbo.Bank.Name AS BankName, 
               dbo.PaymentOthersAgentToAgent.AchDate, 
               dbo.PaymentOthersAgentToAgent.MoneyOrderNumber, 
               dbo.PaymentOthersAgentToAgent.CheckNumber, 
               dbo.PaymentOthersAgentToAgent.CheckDate, 
               Agencies_2.Name AS AgencyName, 
               Agencies_2.Code AS AgencyCode
        FROM dbo.Bank
             INNER JOIN dbo.BankAccounts ON dbo.Bank.BankId = dbo.BankAccounts.BankId
             RIGHT OUTER JOIN dbo.PaymentOthersAgentToAgent
             INNER JOIN dbo.Agencies ON dbo.PaymentOthersAgentToAgent.FromAgency = dbo.Agencies.AgencyId
             INNER JOIN dbo.Agencies AS Agencies_1 ON dbo.PaymentOthersAgentToAgent.ToAgency = Agencies_1.AgencyId
             LEFT OUTER JOIN dbo.Users ON dbo.PaymentOthersAgentToAgent.DeletedBy = dbo.Users.UserId
             INNER JOIN dbo.Users AS Users1 ON dbo.PaymentOthersAgentToAgent.CreatedBy = Users1.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PaymentOthersAgentToAgent.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId ON dbo.BankAccounts.BankAccountId = dbo.PaymentOthersAgentToAgent.BankAccountId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PaymentOthersAgentToAgent.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Agencies AS Agencies_2 ON dbo.PaymentOthersAgentToAgent.AgencyId = Agencies_2.AgencyId
        WHERE dbo.PaymentOthersAgentToAgent.FromAgency = @AgencyFromId
              AND dbo.PaymentOthersAgentToAgent.ToAgency = @AgencyToId
              AND CAST(dbo.PaymentOthersAgentToAgent.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
              AND CAST(dbo.PaymentOthersAgentToAgent.CreationDate AS DATE) <= CAST(@DateTo AS DATE);
    END;
GO