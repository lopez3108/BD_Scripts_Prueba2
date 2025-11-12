SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCardBankByBankAccount] @BankAccountId INT, 
                                                    @Active        BIT = NULL,
										   @UserId         INT        = NULL,
										   @Date         DATETIME        = NULL
AS
    BEGIN
        SELECT dbo.CardBanks.CardBankId, 
               ba.AccountNumber +  '-' + dbo.CardBanks.CardNumber + ' ' + '(' + b.Name + ')' as CardNumber, 
			   dbo.CardBanks.CardNumber as CardNumberSingle, 
			   '****  ' + dbo.CardBanks.CardNumber as CardNumberShort, 
               dbo.CardBanksXBankAccounts.BankAccountId, 
               dbo.CardBanks.Active,
			   
CASE 
WHEN @UserId IS NULL THEN
CAST(0 as BIT) ELSE
CASE WHEN
(dbo.CardBanks.CreatedBy = @UserId AND CAST(dbo.CardBanks.CreationDate as DATE) = CAST(@Date as Date)) THEN
CAST(1 as BIT) ELSE
CAST(0 as BIT) END END as Editable
        FROM dbo.CardBanks
             INNER JOIN dbo.CardBanksXBankAccounts ON dbo.CardBanks.CardBankId = dbo.CardBanksXBankAccounts.CardBankId
				 INNER JOIN BankAccounts ba ON BA.BankAccountId = dbo.CardBanksXBankAccounts.BankAccountId
	    INNER JOIN Bank B ON B.BankId = BA.BankId
        WHERE dbo.CardBanksXBankAccounts.BankAccountId = @BankAccountId
              AND dbo.CardBanks.Active = CASE
                                             WHEN @Active IS NULL
                                             THEN dbo.CardBanks.Active
                                             ELSE @Active
                                         END;
    END;
GO