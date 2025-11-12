SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-03 DJ/6023: Calculates a insurance adjustment usd
-- 2025-01-15 DJ/6260: Adicionar comisiones al momento de ajustar un insurance
-- 2025-02-12 JT/6329: Fix error in calculated adjustment when is paid by ACH
CREATE FUNCTION [dbo].[fn_CalculateInsuranceAdjustment] (@InsurancePolicyId INT = NULL,
@InsuranceMonthlyPaymentId INT = NULL,
@InsuranceRegistrationId INT = NULL)
RETURNS DECIMAL(18, 2)
AS
BEGIN

  DECLARE @result DECIMAL(18, 2)
         ,@insurancePaymentTypeCode VARCHAR(5)
         ,@validatedUsd DECIMAL(18, 2)
         ,@usd DECIMAL(18, 2)
  DECLARE @totalToPay DECIMAL(18, 2)
         ,@feeService DECIMAL(18, 2)
         ,@cardFee DECIMAL(18, 2)
         ,@commissionUsd DECIMAL(18, 2)

  SET @result = 0

  IF (@InsurancePolicyId IS NOT NULL)
  BEGIN

    SET @insurancePaymentTypeCode = (SELECT TOP 1
        Code
      FROM dbo.InsurancePaymentType i
      WHERE i.InsurancePaymentTypeId = (SELECT TOP 1
          InsurancePaymentTypeId
        FROM dbo.InsurancePolicy i
        WHERE i.InsurancePolicyId = @InsurancePolicyId))

    IF (@insurancePaymentTypeCode = 'C01') --CASH
    BEGIN

      SET @validatedUsd = -(SELECT TOP 1
          i.ValidatedUSD
        FROM dbo.InsurancePolicy i
        WHERE i.InsurancePolicyId = @InsurancePolicyId)

    END
    ELSE --ACH
    BEGIN

      SET @validatedUsd = dbo.fn_CalculateInsuranceAchUsd(@InsurancePolicyId, NULL, NULL)

    END

    (SELECT TOP 1
      @usd = i.USD
     ,@feeService = ISNULL(i.FeeService, 0)
     ,@cardFee = ISNULL(i.CardFee, 0)
     ,@commissionUsd = ISNULL(i.CommissionUsd, 0)
    FROM dbo.InsurancePolicy i
    WHERE i.InsurancePolicyId = @InsurancePolicyId)

    SET @totalToPay = @usd + @feeService + @cardFee

    SET @result = @totalToPay - @feeService - @cardFee - @commissionUsd + (@validatedUsd)

  END

  IF (@InsuranceMonthlyPaymentId IS NOT NULL)
  BEGIN

    SET @insurancePaymentTypeCode = (SELECT TOP 1
        Code
      FROM dbo.InsurancePaymentType i
      WHERE i.InsurancePaymentTypeId = (SELECT TOP 1
          InsurancePaymentTypeId
        FROM dbo.InsuranceMonthlyPayment i
        WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId))

    IF (@insurancePaymentTypeCode = 'C01') --CASH
    BEGIN

      SET @validatedUsd = -(SELECT TOP 1
          i.ValidatedUSD
        FROM dbo.InsuranceMonthlyPayment i
        WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

    END
    ELSE --ACH
    BEGIN

      SET @validatedUsd = dbo.fn_CalculateInsuranceAchUsd(NULL, @InsuranceMonthlyPaymentId, NULL)

    END

    (SELECT TOP 1
      @usd = i.USD
     ,@feeService = ISNULL(i.MonthlyPaymentServiceFee, 0)
     ,@cardFee = ISNULL(i.CardFee, 0)
     ,@commissionUsd = ISNULL(i.CommissionUsd, 0)
    FROM dbo.InsuranceMonthlyPayment i
    WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

    SET @totalToPay = @usd + @feeService + @cardFee

    SET @result = @totalToPay - @feeService - @cardFee - @commissionUsd + (@validatedUsd)

  END

  IF (@InsuranceRegistrationId IS NOT NULL)
  BEGIN


    SET @insurancePaymentTypeCode = (SELECT TOP 1
        Code
      FROM dbo.InsurancePaymentType i
      WHERE i.InsurancePaymentTypeId = (SELECT TOP 1
          InsurancePaymentTypeId
        FROM dbo.InsuranceRegistration i
        WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId))

    IF (@insurancePaymentTypeCode = 'C01') --CASH
    BEGIN

      SET @validatedUsd = -(SELECT TOP 1
          i.ValidatedUSD
        FROM dbo.InsuranceRegistration i
        WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

    END
    ELSE --ACH
    BEGIN

      SET @validatedUsd = dbo.fn_CalculateInsuranceAchUsd(NULL, NULL, @InsuranceRegistrationId)

    END

    (SELECT TOP 1
      @usd = ISNULL(i.USD,0)
     ,@feeService = ISNULL(i.RegistrationReleaseSOSFee,0)
     ,@cardFee = ISNULL(i.CardFee,0)
     ,@commissionUsd = 0
    FROM dbo.InsuranceRegistration i
    WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

    SET @totalToPay = @usd + @feeService + @cardFee

    SET @result = @totalToPay - @feeService - @cardFee + ISNULL(@validatedUsd,0)



  END

  RETURN @result

END



GO