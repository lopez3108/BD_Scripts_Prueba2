SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentAdjustment]

@PaymentAdjustmentId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


UPDATE [dbo].[PaymentAdjustment]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
 WHERE PaymentAdjustmentId = @PaymentAdjustmentId

 SELECT @PaymentAdjustmentId


     END;
GO