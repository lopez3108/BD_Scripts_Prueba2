SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteConciliationCardPayment] 
@ConciliationCardPaymentId INT,
@CurrentDate DATETIME
AS
     BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM ConciliationCardPayments WHERE
ConciliationCardPaymentId = @ConciliationCardPaymentId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE FROM [dbo].[ConciliationCardPaymentsDetails]
      WHERE ConciliationCardPaymentId = @ConciliationCardPaymentId

DELETE FROM [dbo].ConciliationCardPayments
      WHERE ConciliationCardPaymentId = @ConciliationCardPaymentId

SELECT @ConciliationCardPaymentId

END

END
GO