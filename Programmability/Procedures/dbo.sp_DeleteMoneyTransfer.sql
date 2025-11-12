SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteMoneyTransfer]
 (
 @MoneyTransfersId int

    )
AS 

BEGIN

DELETE FROM [dbo].[MoneyTransfers]
      WHERE MoneyTransfersId = @MoneyTransfersId


	END


GO