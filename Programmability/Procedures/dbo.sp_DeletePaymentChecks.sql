SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentChecks]

@PaymentChecksId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


UPDATE [dbo].[PaymentChecks]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
 WHERE PaymentCheckId = @PaymentChecksId

 SELECT @PaymentChecksId


     END;
GO