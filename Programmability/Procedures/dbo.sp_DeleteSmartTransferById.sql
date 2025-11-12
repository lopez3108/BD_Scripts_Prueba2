SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSmartTransferById](@SmartSafeDepositId INT)
AS
     BEGIN
		 DELETE FROM dbo.SmartSafeDeposit
		 WHERE
			SmartSafeDepositId = @SmartSafeDepositId
         
     END;
GO