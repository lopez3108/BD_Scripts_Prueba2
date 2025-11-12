SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAccountOwner] 
@AccountOwnerId INT = NULL
AS
     BEGIN

	
	
	  IF(EXISTS(SELECT 1 FROM [BankAccountsXProviderBanks] WHERE AccountOwnerId = @AccountOwnerId))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

	 DELETE AccountOwners WHERE AccountOwnerId = @AccountOwnerId


	 SELECT @AccountOwnerId

	 END
	 
END
GO