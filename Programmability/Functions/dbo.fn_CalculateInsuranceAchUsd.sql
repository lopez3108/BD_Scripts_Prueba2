SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-23 DJ/6020: Calculates a insurance Ach payments total
-- 2025-01-30 JF/6325: Mostrar ajuste sin validar en la grid de INSURANCE
-- 2025-02-12 JT/6329: Fix error in calculated adjustment when is paid by ACH

CREATE FUNCTION [dbo].[fn_CalculateInsuranceAchUsd] (@InsurancePolicyId INT = NULL,
@InsuranceMonthlyPaymentId INT = NULL,
@InsuranceRegistrationId INT = NULL)
RETURNS DECIMAL(18, 2)
AS
BEGIN

  DECLARE @result DECIMAL(18, 2)
  SET @result = 0

  IF (@InsurancePolicyId IS NOT NULL)
  BEGIN

    SET @result = (SELECT
        SUM(
        CASE
          WHEN i.TypeId = 1 THEN -i.USD
          ELSE i.USD
        END
        )
      FROM dbo.InsuranceAchPayment i
      WHERE i.InsurancePolicyId = @InsurancePolicyId);

  END

  IF (@InsuranceMonthlyPaymentId IS NOT NULL)
  BEGIN

    SET @result = (SELECT
       SUM(
        CASE
          WHEN i.TypeId = 1 THEN -i.USD
          ELSE i.USD
        END
        )
      FROM dbo.InsuranceAchPayment i
      WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

  END

  IF (@InsuranceRegistrationId IS NOT NULL)
  BEGIN

    SET @result = (SELECT
        SUM(
        CASE
          WHEN i.TypeId = 1 THEN -i.USD
          ELSE i.USD
        END
        )
      FROM dbo.InsuranceAchPayment i
      WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

  END

  RETURN ISNULL(@result, 0)

END

GO