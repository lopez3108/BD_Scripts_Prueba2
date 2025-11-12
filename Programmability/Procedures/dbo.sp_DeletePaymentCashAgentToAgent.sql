SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentCashAgentToAgent]

@PaymentCashId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


UPDATE [dbo].[PaymentCashAgentToAgent]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
 WHERE PaymentCashId = @PaymentCashId

 SELECT @PaymentCashId


     END;
GO