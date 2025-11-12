SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ActiveInactiveAccountOwner] 
@AccountOwnerId INT,
@Active BIT
AS
     BEGIN

	 UPDATE AccountOwners SET Active = @Active WHERE 
	 AccountOwnerId = @AccountOwnerId

	 UPDATE BankAccounts SET Active = @Active WHERE
	 BankAccountId IN (SELECT bp.BankAccountId FROM BankAccountsXProviderBanks bp
	 WHERE bp.AccountOwnerId = @AccountOwnerId)

	 UPDATE CardBanks SET Active = @Active WHERE 
	 CardBankId IN (SELECT        dbo.CardBanksXBankAccounts.CardBankId
FROM            dbo.BankAccountsXProviderBanks INNER JOIN
                         dbo.BankAccounts ON dbo.BankAccountsXProviderBanks.BankAccountId = dbo.BankAccounts.BankAccountId INNER JOIN
                         dbo.CardBanksXBankAccounts ON dbo.BankAccounts.BankAccountId = dbo.CardBanksXBankAccounts.BankAccountId
						 WHERE dbo.BankAccountsXProviderBanks.AccountOwnerId = @AccountOwnerId)
	 
END
GO