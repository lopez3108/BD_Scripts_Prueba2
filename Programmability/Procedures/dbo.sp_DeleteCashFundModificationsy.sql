SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteCashFundModificationsy](@CashFundModificationsId INT)
AS
BEGIN
    DELETE [CashFundModifications]
    WHERE CashFundModificationsId = @CashFundModificationsId;

END;
GO