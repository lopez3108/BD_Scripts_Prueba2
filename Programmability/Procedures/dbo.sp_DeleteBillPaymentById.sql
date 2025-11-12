SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteBillPaymentById](@BillPaymentId INT)
AS
     BEGIN
         DELETE FROM BillPayments
         WHERE BillPaymentId = @BillPaymentId;
        
     END;
GO