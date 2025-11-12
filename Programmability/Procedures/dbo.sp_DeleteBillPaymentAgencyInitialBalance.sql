SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteBillPaymentAgencyInitialBalance] 
@ProviderId INT
AS
     BEGIN
         
DELETE FROM [dbo].[BillPaymentxAgencyInitialBalances]
      WHERE ProviderId = @ProviderId








     END;
GO