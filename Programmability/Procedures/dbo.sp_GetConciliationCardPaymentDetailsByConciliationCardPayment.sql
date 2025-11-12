SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationCardPaymentDetailsByConciliationCardPayment] 
@ConciliationCardPaymentId INT = NULL
AS
     BEGIN

SELECT [Usd]
  FROM [dbo].[ConciliationCardPaymentsDetails]
  WHERE [ConciliationCardPaymentId] = @ConciliationCardPaymentId

END
GO