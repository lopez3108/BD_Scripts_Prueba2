SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDailyDistributionByCashierByDate] 
@CashierId INT,
@AgencyId INT,
@Date DATE
AS
     BEGIN
        

SELECT        
dbo.DailyDistribution.DailyDistributionId, 
dbo.DailyDistribution.DailyId,  
dbo.DailyDistribution.Usd, 
dbo.DailyDistribution.PackageNumber, 
dbo.Daily.DailyId AS Expr1, 
dbo.Daily.CashierId, 
dbo.Daily.AgencyId, 
dbo.Daily.CreationDate, 
dbo.Daily.CreationDate as DistributionDate,
dbo.Daily.Total, 
dbo.Daily.Cash, 
dbo.Agencies.Name, 
dbo.Agencies.Code, 
dbo.Providers.Name AS ProviderName, 
dbo.BankAccounts.BankAccountId, 
dbo.BankAccounts.BankId, 
dbo.BankAccounts.AccountNumber, 
dbo.Bank.Name AS BankName, 
dbo.DailyDistribution.ProviderId, 
dbo.DailyDistribution.Code AS Expr2, 
Agencies_1.Name AS Expr3,
dbo.Providers.Name + ' (' + dbo.DailyDistribution.Code + ')' + ' / ' + Agencies_1.Code + ' - ' + Agencies_1.Name as ProviderMoneyName,
('**** ' +  dbo.BankAccounts.AccountNumber +' ' + dbo.Bank.Name) as BankNameNumberFormat
FROM            dbo.DailyDistribution INNER JOIN
                         dbo.Daily ON dbo.DailyDistribution.DailyId = dbo.Daily.DailyId INNER JOIN
                         dbo.Agencies ON dbo.Daily.AgencyId = dbo.Agencies.AgencyId LEFT OUTER JOIN
                         dbo.Agencies AS Agencies_1 ON dbo.DailyDistribution.AgencyId = Agencies_1.AgencyId LEFT OUTER JOIN
                         dbo.Providers ON dbo.DailyDistribution.ProviderId = dbo.Providers.ProviderId LEFT OUTER JOIN
                         dbo.Bank INNER JOIN
                         dbo.BankAccounts ON dbo.Bank.BankId = dbo.BankAccounts.BankId ON dbo.DailyDistribution.BankAccountId = dbo.BankAccounts.BankAccountId
						 WHERE
						 dbo.Daily.CashierId = @CashierId AND
						 dbo.Daily.AgencyId = @AgencyId AND
						 CAST(dbo.Daily.CreationDate as DATE) =  CAST(@Date as DATE)


     END;
GO