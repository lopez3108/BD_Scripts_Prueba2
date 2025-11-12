SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCahiersMoneyDistribution] @CashierId     INT = NULL,
                                                          @MoneyTransferxAgencyNumbersId      INT = NULL,
                                                          @BankAccountId INT = NULL,
														  @Active BIT = NULL
AS
     BEGIN

	 IF(@Active IS NULL)
	 BEGIN

	 SET @Active = 1

	 END


       SELECT  
	   m.MoneyDistributionId,      
	   m.CashierId, 
	   u.Name AS Cashier,
	   p.Name + ' (' + mt.Number + ')' + ' / ' + a.Code + ' - ' + a.Name as ProviderName,
				('**** ' +  ba.AccountNumber +' ' + bk.Name) as BankAccountName,
				m.IsDefault,

				CASE
                   WHEN  m.IsDefault = 1
                   THEN 'YES'
                   ELSE 'NO'
                END AS [IsDefaulFormat],

				m.MoneyTransferxAgencyNumbersId,
				m.BankAccountId,
				m.Active
FROM            dbo.Bank AS bk INNER JOIN
                         dbo.BankAccounts AS ba ON bk.BankId = ba.BankId RIGHT OUTER JOIN
                         dbo.Providers AS p INNER JOIN
                         dbo.MoneyTransferxAgencyNumbers AS mt ON p.ProviderId = mt.ProviderId INNER JOIN
                         dbo.Agencies AS a ON a.AgencyId = mt.AgencyId RIGHT OUTER JOIN
                         dbo.MoneyDistribution AS m INNER JOIN
                         dbo.Cashiers AS c ON c.CashierId = m.CashierId INNER JOIN
                         dbo.Users AS u ON u.UserId = c.UserId ON mt.MoneyTransferxAgencyNumbersId = m.MoneyTransferxAgencyNumbersId ON ba.BankAccountId = m.BankAccountId
         WHERE
		 c.IsActive = 1 AND
		 (m.CashierId = @CashierId
               OR @CashierId IS NULL) AND
			   (m.MoneyTransferxAgencyNumbersId = @MoneyTransferxAgencyNumbersId
               OR @MoneyTransferxAgencyNumbersId IS NULL) AND
			   (m.BankAccountId = @BankAccountId
               OR @BankAccountId IS NULL) AND
			   (m.Active = @Active OR @Active IS NULL)
			   ORDER BY c.CashierId ASC, m.IsDefault DESC
            
     END;
GO