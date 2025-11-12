SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/29-08-2025 task 6736 Pagar menos de lo disponible cuando se hace Money distribution



CREATE PROCEDURE [dbo].[sp_GetDailyDistributionCashierDailyId] 
  @DailyId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Name + ' (' + ISNULL(mt.Number, '-') + ') / ' + a.Code + ' - ' + a.Name AS ProviderName,
         ' (' + ISNULL(mt.Number, '-') + ') / ' + a.Code  AS CodeProviderAgency,
        ('**** ' + ba.AccountNumber + ' ' + b.Name) AS BankAccountName,
        dd.*
     
      FROM DailyDistribution dd
    LEFT JOIN Providers p 
        ON dd.ProviderId = p.ProviderId
    LEFT JOIN Agencies a 
        ON dd.AgencyId = a.AgencyId
    LEFT JOIN MoneyTransferxAgencyNumbers mt 
        ON mt.ProviderId = dd.ProviderId
       AND mt.AgencyId = dd.AgencyId
    LEFT JOIN BankAccounts ba 
        ON dd.BankAccountId = ba.BankAccountId
    LEFT JOIN Bank b 
        ON ba.BankId = b.BankId

    WHERE dd.DailyId = @DailyId;

END;

GO