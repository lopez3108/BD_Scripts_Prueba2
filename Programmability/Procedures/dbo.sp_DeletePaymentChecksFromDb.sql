SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentChecksFromDb](@PaymentCheckId INT)
AS
     BEGIN
         DELETE [PaymentChecks]
         WHERE PaymentCheckId = @PaymentCheckId;

     END;
GO