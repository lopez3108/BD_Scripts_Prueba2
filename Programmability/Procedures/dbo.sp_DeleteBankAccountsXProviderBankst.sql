SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteBankAccountsXProviderBankst]
 (
      @BankAccountId int
    )
AS 

BEGIN


--DELETE [dbo].[BankAccountsXProviderBanks] WHERE BankAccountId = @BankAccountId
DELETE BankAccountsXProviderBanks WHERE BankAccountId = @BankAccountId 

SELECT 1


	END



GO