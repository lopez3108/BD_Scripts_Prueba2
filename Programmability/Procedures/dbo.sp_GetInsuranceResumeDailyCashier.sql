SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-02 JT/6039: (Add new filter DateTo and return Date for each day)
-- 2024-08-29 DJ/6016: Gets cashier insurance daily resume
-- 2024-12-27 DJ/6266: Aplicar comisión provider a los insurance - NEW POLICY
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-02-12 JT/6329: Fix error in calculated adjustment when is paid by ACH

CREATE PROCEDURE [dbo].[sp_GetInsuranceResumeDailyCashier] @CreatedBy INT,
@Date DATETIME,
@DateTo DATETIME = NULL,
@AgencyId INT
AS
BEGIN
  -- Ensure @DateTo has value
  IF @DateTo IS NULL
    SET @DateTo = @Date

  -- Crear tabla temporal para almacenar los resultados
  CREATE TABLE #DailyCashierResume (
    Date DATE
   ,NewPolicy DECIMAL(18, 2)
   ,MonthlyPayment DECIMAL(18, 2)
   ,RegistratioRelease DECIMAL(18, 2)
   ,Adjustment DECIMAL(18, 2)
   ,Total DECIMAL(18, 2)
  )

  -- Generate date range between @Date and @DateTo for later information search for each date
  DECLARE @CurrentDate DATE = @Date

  WHILE @CurrentDate <= @DateTo
  BEGIN
  DECLARE @newPolicy DECIMAL(18, 2)
  SET @newPolicy = (SELECT
      SUM(USD + FeeService)
    FROM dbo.FN_GetInsurancePolicies(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate))

  DECLARE @monthtly DECIMAL(18, 2)
  SET @monthtly = (SELECT
      SUM(USD + MonthlyPaymentServiceFee)
    FROM dbo.FN_GetInsuranceMonthlyPayments(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate))

  DECLARE @registration DECIMAL(18, 2)
  SET @registration = (SELECT
      SUM(USD + RegistrationReleaseSOSFee)
    FROM dbo.FN_GetInsuranceRegistration(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate))

  DECLARE @adjustmentPolicy DECIMAL(18, 2)
  SET @adjustmentPolicy = ISNULL((SELECT
      SUM(
      (f.USD + ISNULL(f.FeeService, 0) + ISNULL(f.CardFee, 0)) -
      ISNULL(f.FeeService, 0) -
      ISNULL(f.CardFee, 0) -
      ISNULL(f.CommissionUsd, 0) +
      ((CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(f.InsurancePolicyId, NULL, NULL)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END)))
    FROM dbo.FN_GetInsurancePolicies(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate) f
    WHERE f.PaymentStatusCode = 'C02')
  , 0)

  DECLARE @adjustmentMonthly DECIMAL(18, 2)
  SET @adjustmentMonthly = ISNULL((SELECT
      SUM(
      (f.USD + ISNULL(f.MonthlyPaymentServiceFee, 0) + ISNULL(f.CardFee, 0)) -
      ISNULL(f.MonthlyPaymentServiceFee, 0) -
      ISNULL(f.CardFee, 0) -
      ISNULL(f.CommissionUsd, 0) +
      ((CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(NULL, f.InsuranceMonthlyPaymentId, NULL)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END)))
    FROM dbo.FN_GetInsuranceMonthlyPayments(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate) f
    WHERE f.PaymentStatusCode = 'C02')
  , 0)

  DECLARE @adjustmentRegistration DECIMAL(18, 2)
  SET @adjustmentRegistration = ISNULL((SELECT
      SUM(
      (f.USD + ISNULL(f.RegistrationReleaseSOSFee, 0) + ISNULL(f.CardFee, 0)) -
      ISNULL(f.RegistrationReleaseSOSFee, 0) -
      ISNULL(f.CardFee, 0) -
      ISNULL(f.CommissionUsd, 0) +
      ((CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(NULL, NULL, f.InsuranceRegistrationId)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END)))
    FROM dbo.FN_GetInsuranceRegistration(@AgencyId, @CreatedBy, @CurrentDate, @CurrentDate) f
    WHERE f.PaymentStatusCode = 'C02')
  , 0)

  DECLARE @adjustmentTotal DECIMAL(18, 2)
  SET @adjustmentTotal = (@adjustmentPolicy + @adjustmentMonthly + @adjustmentRegistration) * -1

  -- Insert the values in temp tbl
  INSERT INTO #DailyCashierResume (Date, NewPolicy, MonthlyPayment, RegistratioRelease, Adjustment, Total)
    VALUES (@CurrentDate, ISNULL(@newPolicy, 0), ISNULL(@monthtly, 0), ISNULL(@registration, 0), ISNULL(@adjustmentTotal, 0), ISNULL(@newPolicy, 0) + ISNULL(@monthtly, 0) + ISNULL(@registration, 0) + ISNULL(@adjustmentTotal, 0))

  -- Add date
  SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
  END

  --Select the result
  SELECT
    *
  FROM #DailyCashierResume

  -- Clean tmp table
  DROP TABLE #DailyCashierResume
END

GO