SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteCardBank] 
@CardBankId INT
AS
     BEGIN

	DELETE dbo.CardBanksXBankAccounts WHERE CardBankId = @CardBankId

	DELETE dbo.CardBanks WHERE CardBankId = @CardBankId

	SELECT @CardBankId

	END

GO