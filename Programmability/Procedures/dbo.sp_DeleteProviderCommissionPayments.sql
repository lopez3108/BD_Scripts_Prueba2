SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- task 6632 10-junio de 2025 Comisiones tickets JF

CREATE PROCEDURE [dbo].[sp_DeleteProviderCommissionPayments] (@ProviderCommissionPaymentId INT,
@Date DATETIME)
AS
BEGIN

  DECLARE @creationDate DATETIME
  SET @creationDate = (SELECT TOP 1
      CreationDate
    FROM ProviderCommissionPayments p
    WHERE p.ProviderCommissionPaymentId = @ProviderCommissionPaymentId)

  DECLARE @providerId DATETIME
  SET @providerId = (SELECT TOP 1
      ProviderId
    FROM ProviderCommissionPayments p
    WHERE p.ProviderCommissionPaymentId = @ProviderCommissionPaymentId)

  IF (CAST(@creationDate AS DATE) <> CAST(@Date AS DATE))
  BEGIN

    SELECT
      -1

  END
  ELSE
  BEGIN



    IF (EXISTS (SELECT
          InsuranceProviderCommissionPaymentId
        FROM InsuranceProviderCommissionPayment i
        WHERE i.ProviderCommissionPaymentId = @ProviderCommissionPaymentId)
      )
    BEGIN

      DELETE InsuranceProviderCommissionPayment
      WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId

    END

   
    IF (@providerId = 24) -- Esto aplica unicamente para tikets
    BEGIN
      UPDATE Tickets
      SET ProviderCommissionPaymentId = NULL
      WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId
    END


    DELETE ProviderCommissionPayments
    WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId

    SELECT
      @ProviderCommissionPaymentId

  END




END;
GO