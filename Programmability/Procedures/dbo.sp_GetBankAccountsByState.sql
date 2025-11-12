SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBankAccountsByState] @Active BIT = NULL
AS
     BEGIN
         SELECT ba.BankAccountId,
                ba.BankId,
                '**** '+ ba.AccountNumber  + ' ' + '(' + b.Name + ')' AS AccountNumber,
                Active
         FROM dbo.BankAccounts ba
	       INNER JOIN Bank B ON B.BankId = ba.BankId
         WHERE ba.Active = @Active
               OR @Active IS NULL;
     END;
GO