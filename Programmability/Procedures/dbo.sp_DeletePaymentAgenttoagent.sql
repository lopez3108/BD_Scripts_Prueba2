SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeletePaymentAgenttoagent]

@PaymentOthersAgentToAgentId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


UPDATE [dbo].[PaymentOthersAgentToAgent]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
	  ,[StatusId] = 0
 WHERE PaymentOthersAgentToAgentId = @PaymentOthersAgentToAgentId

 SELECT @PaymentOthersAgentToAgentId


     END;
GO