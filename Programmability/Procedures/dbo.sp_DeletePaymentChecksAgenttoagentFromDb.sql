SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeletePaymentChecksAgenttoagentFromDb](@PaymentChecksAgentToAgentId INT)
AS
     BEGIN
         DELETE PaymentChecksAgentToAgent
         WHERE PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId;

     END;
GO