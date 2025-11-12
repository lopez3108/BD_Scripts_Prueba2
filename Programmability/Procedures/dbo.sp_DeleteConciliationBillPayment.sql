SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteConciliationBillPayment] @ConciliationBillPaymentId INT = NULL,
@CurrentDate DATETIME
AS
BEGIN

  IF (CAST(@CurrentDate AS DATE) <> (SELECT TOP 1
        CAST(CreationDate AS DATE)
      FROM ConciliationBillPayments
      WHERE ConciliationBillPaymentId = @ConciliationBillPaymentId)
    )
  BEGIN

    SELECT
      -1

  END
  ELSE
  BEGIN

    DELETE ConciliationBillPayments
    WHERE ConciliationBillPaymentId = @ConciliationBillPaymentId

    SELECT
      @ConciliationBillPaymentId

  END

END

GO