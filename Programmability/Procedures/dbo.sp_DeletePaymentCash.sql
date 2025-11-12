SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentCash]

@PaymentCashId INT,
@DeletedOn DATETIME,
@DeletedBy INT,
@Status INT

AS
     BEGIN


UPDATE [dbo].[PaymentCash]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy,
	  Status = @Status
 WHERE PaymentCashId = @PaymentCashId

 SELECT @PaymentCashId


     END;
GO