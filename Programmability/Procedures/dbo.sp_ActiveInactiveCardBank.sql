SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ActiveInactiveCardBank] 
@CardBankId INT,
@Active BIT
AS
     BEGIN

	 UPDATE CardBanks SET Active = @Active WHERE CardBankId = @CardBankId
	

END
GO