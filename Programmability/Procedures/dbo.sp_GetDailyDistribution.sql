SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDailyDistribution] @CashierId     INT      = NULL, 
                                                @AgencyId      INT      = NULL, 
                                                @ProviderId    INT      = NULL, 
                                                @BankAccountId INT      = NULL, 
                                                @Date          DATETIME = NULL
AS
    BEGIN
        SELECT dbo.DailyDistribution.DailyDistributionId, 
               dbo.DailyDistribution.DailyId, 
               dbo.DailyDistribution.Usd, 
               dbo.DailyDistribution.PackageNumber, 
               dbo.Daily.DailyId AS Expr1, 
               dbo.Daily.CashierId, 
               dbo.Daily.AgencyId, 
			   dbo.Daily.CreationDate DailyDate,
			   FORMAT(Daily.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DailyDateFormat,
               dbo.DailyDistribution.CreationDate,
			   FORMAT(DailyDistribution.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
			   dbo.DailyDistribution.UpdatedOn,
			   FORMAT(DailyDistribution.UpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  UpdatedOnFormat,
               dbo.Daily.Total, 
               dbo.Daily.Cash, 
               dbo.Agencies.Name, 
               dbo.Agencies.Code,
			   dbo.Agencies.Code + ' - ' + dbo.Agencies.Name Agency,
               dbo.Providers.Name AS ProviderName, 
               dbo.BankAccounts.BankAccountId, 
               dbo.BankAccounts.BankId, 
               dbo.BankAccounts.AccountNumber, 
               dbo.Bank.Name AS BankName, 
               dbo.DailyDistribution.ProviderId, 
               dbo.DailyDistribution.Code AS Expr2, 
               Agencies_1.Name AS Expr3, 
               dbo.Providers.Name + ' (' + dbo.DailyDistribution.Code + ')' + ' / ' + Agencies_1.Code + ' - ' + Agencies_1.Name AS ProviderMoneyName, 
               '**** ' + dbo.BankAccounts.AccountNumber + ' ' + dbo.Bank.Name AS BankNameNumberFormat, 
               dbo.Users.Name AS Cashier, 
               dbo.Users.Name AS CashierName, 
               dbo.Daily.ClosedOn AS ClosedOn, 
               dbo.Agencies.Code AS AgencyName, 
               dbo.Users.UserId, 
               --CAST(1 AS BIT) AS HasDocument,
               CASE
                   WHEN dbo.DailyDistribution.PackageNumber IS NULL
                   THEN CAST(0 AS BIT)
                   ELSE CAST(1 AS BIT)
               END AS Sent,
			    ImageName, 
                 ImageNameBook,
				 uu.Name as UpdatedBy,
				 uc.Name as CreatedBy,
				 Users.Name as DailyBy
        FROM  dbo.DailyDistribution
                  INNER JOIN dbo.Daily ON dbo.DailyDistribution.DailyId = dbo.Daily.DailyId
                  INNER JOIN dbo.Agencies ON dbo.Daily.AgencyId = dbo.Agencies.AgencyId
                  INNER JOIN dbo.Cashiers ON dbo.Daily.CashierId = dbo.Cashiers.CashierId
                  INNER JOIN dbo.Users ON dbo.Cashiers.UserId = dbo.Users.UserId
	              LEFT OUTER JOIN dbo.Users uc ON dbo.DailyDistribution.CreatedBy = uc.UserId
				  LEFT OUTER JOIN dbo.Users uu ON dbo.DailyDistribution.UpdatedBy = uu.UserId
                  LEFT OUTER JOIN dbo.Agencies AS Agencies_1 ON dbo.DailyDistribution.AgencyId = Agencies_1.AgencyId
                  LEFT OUTER JOIN dbo.Providers ON dbo.DailyDistribution.ProviderId = dbo.Providers.ProviderId
                  LEFT OUTER JOIN dbo.Bank
                  INNER JOIN dbo.BankAccounts ON dbo.Bank.BankId = dbo.BankAccounts.BankId ON dbo.DailyDistribution.BankAccountId = dbo.BankAccounts.BankAccountId
				  INNER JOIN dbo.Users u ON dbo.Daily.ClosedBy = u.UserId
             WHERE(dbo.Daily.CashierId = @CashierId
                   OR @CashierId IS NULL)
                  AND (dbo.Daily.AgencyId = @AgencyId
                       OR @AgencyId IS NULL)
                  AND (dbo.DailyDistribution.ProviderId = @ProviderId
                       OR @ProviderId IS NULL)
                  AND (dbo.DailyDistribution.BankAccountId = @BankAccountId
                       OR @BankAccountId IS NULL)
                  AND (CAST(dbo.Daily.CreationDate AS DATE) = CAST(@Date AS DATE)
                       OR @Date IS NULL);
    END;
GO