SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteMoneyTransferById](@MoneyTransfersId INT)
AS
     BEGIN
         DELETE FROM MoneyTransfers
         WHERE MoneyTransfersId = @MoneyTransfersId;
     END;
GO