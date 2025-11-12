SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateAccountOwner] 
@AccountOwnerId INT = NULL,
@Name VARCHAR(50),
@Active BIT
AS
     BEGIN


	  IF(EXISTS(SELECT 1 FROM [AccountOwners] WHERE Name = @Name AND
	  (@AccountOwnerId IS NULL OR AccountOwnerId <> @AccountOwnerId)))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

	 IF(@AccountOwnerId IS NULL)
	 BEGIN

	 INSERT INTO [dbo].[AccountOwners]
           ([Name],
		   [Active])
     VALUES
           (@Name,
		   @Active)


 SELECT @@IDENTITY


	 END
	 ELSE
	 BEGIN

	 UPDATE [AccountOwners] SET Name = @Name 
	 WHERE AccountOwnerId = @AccountOwnerId

	 DECLARE @actualActive BIT
	 SET @actualActive = (SELECT TOP 1 Active FROM [AccountOwners]
	 WHERE AccountOwnerId = @AccountOwnerId)
	 
	 IF (@actualActive <> @Active)
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


	 END

	 END

	 END
GO