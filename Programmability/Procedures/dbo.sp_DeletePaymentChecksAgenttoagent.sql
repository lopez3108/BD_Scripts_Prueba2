SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentChecksAgenttoagent]

@PaymentChecksAgentToAgentId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


UPDATE [dbo].[PaymentChecksAgentToAgent]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
	  ,[StatusId] = 0
 WHERE PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId

 SELECT @PaymentChecksAgentToAgentId


     END;
GO