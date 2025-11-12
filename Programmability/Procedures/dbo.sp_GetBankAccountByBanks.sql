SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	exec [dbo].[sp_GetBankAccountByBanks]
	@BankId = 29,
	@Active = 1
*/
CREATE PROCEDURE [dbo].[sp_GetBankAccountByBanks] @BankId INT, 
                                                    @Active        BIT = NULL
AS
    BEGIN
        SELECT BC.BankAccountId, 
               BC.AccountNumber, 
               BC.BankId, 
               B.Name AS Bank, 
               
               ('**** ' + BC.AccountNumber + ' ' +  '(' + B.Name + ')') AS BankNameNumberFormat
        FROM dbo.BankAccounts BC
             --INNER JOIN dbo.CardBanksXBankAccounts ON dbo.CardBanks.CardBankId = dbo.CardBanksXBankAccounts.CardBankId
				 --INNER JOIN BankAccounts ba ON BA.BankAccountId = dbo.CardBanksXBankAccounts.BankAccountId
	    INNER JOIN Bank B ON B.BankId = BC.BankId
        WHERE BC.BankId = @BankId
              AND (BC.Active = @Active OR @Active IS NULL)
		ORDER BY BankNameNumberFormat
                                          
    END;
GO