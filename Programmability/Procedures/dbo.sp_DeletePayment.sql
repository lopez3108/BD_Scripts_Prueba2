SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePayment](@PaymentId INT)
AS
     BEGIN
         DELETE FROM Payments
         WHERE PaymentId = @PaymentId;
     END;
GO