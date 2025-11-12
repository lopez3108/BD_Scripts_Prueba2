SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteMoneyTransferAgencyInitialBalance] @ProviderId INT
AS
     BEGIN
         DELETE FROM [dbo].[MoneyTransferxAgencyInitialBalances]
         WHERE ProviderId = @ProviderId;
     END;
GO