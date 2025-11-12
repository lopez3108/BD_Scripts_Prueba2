SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCardBanksByState] @Active BIT = NULL
AS
     BEGIN
         SELECT c.CardBankId,
               '**** ' +  ba.AccountNumber +  ' - ' + c.CardNumber + ' ' + '(' + b.Name + ')' as CardNumber ,
              c.Active
         FROM dbo.CardBanks c INNER JOIN  CardBanksXBankAccounts cb on c.CardBankId = cb.CardBankId
	    INNER JOIN BankAccounts ba ON BA.BankAccountId = cb.BankAccountId
	    INNER JOIN Bank B ON B.BankId = BA.BankId
         WHERE c.Active = @Active
               OR @Active IS NULL;
     END;
GO