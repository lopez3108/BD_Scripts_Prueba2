SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-11-28 DJ/6227:  Agregar pagos con tarjeta a los reportes de CARD PAYMENT
-- 2024-11-28 JF /6227: add  i.PaymentType = 'C05' OR i.PaymentType = 'C02' AND  i.CardFee > 0 
-- 2024-12-07   JF /6227: error calculo de comision a pagar no estaba teniendo en cuenta el @Month y @Year se implementó en el condicional 
-- 2025-01-27 JF /6315: REPORTES (CARD PAYMENTS Y BANKS) - TYPE & DESCRIPTION no muestra tipo de servicio correcto
-- 2025-01-28 DJ/6315: REPORTES (CARD PAYMENTS Y BANKS) - TYPE & DESCRIPTION no muestra tipo de servicio correcto

CREATE FUNCTION [dbo].[FN_GenerateInsuranceCardPaymentReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Month INT = NULL,
@Year INT = NULL,
@FromCommissions INT)
RETURNS @result TABLE (
  AgencyId INT
 ,CreationDate DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,Usd DECIMAL(18, 2)
 ,CreatedByName VARCHAR(80)
 ,CardFee DECIMAL(18, 2)
)
AS


BEGIN


  INSERT INTO @result
    SELECT
      q.*
    FROM (
      -- Insurance Policy
      SELECT
        i.CreatedInAgencyId AgencyId
       ,i.CreationDate CreationDate
       ,'NEW POLICY' Description
       ,'NEW POLICY' Type
        ,(i.Usd + ISNULL(i.FeeService, 0)) Usd
--       ,i.Usd Usd
       ,u.Name CreatedByName
       ,ISNULL(i.CardFee, 0) CardFee
      FROM dbo.InsurancePolicy i
      INNER JOIN dbo.Users u
        ON u.UserId = i.CreatedBy
      WHERE (i.PaymentType = 'C05'
      OR i.PaymentType = 'C02'
      AND i.CardFee > 0)
      AND i.CreatedInAgencyId = @AgencyId
      AND (@FromCommissions = 1
      AND (CAST(DATEPART(MONTH, i.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, i.CreationDate) AS INT) = @Year)
      OR @FromCommissions = 0
      AND ((CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)))


      UNION ALL-- Insurance Monthly Payment

      SELECT
        i.CreatedInAgencyId AgencyId
       ,i.CreationDate CreationDate
       ,ict.Description Description
--       ,'MONTHLY PAYMENT' Description
       ,'MONTHLY PAYMENT' Type
       ,(i.Usd + ISNULL(i.MonthlyPaymentServiceFee, 0)) Usd
       ,u.Name CreatedByName
       ,ISNULL(i.CardFee, 0) CardFee
      FROM dbo.InsuranceMonthlyPayment i

      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.PaymentType = 'C05'
      OR i.PaymentType = 'C02'
      AND i.CardFee > 0)
      AND i.CreatedInAgencyId = @AgencyId
      AND (@FromCommissions = 1
      AND (CAST(DATEPART(MONTH, i.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, i.CreationDate) AS INT) = @Year)
      OR @FromCommissions = 0
      AND ((CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL))) AND ict.Code = 'C04'

 UNION ALL-- Insurance endorsement
      SELECT
        i.CreatedInAgencyId AgencyId
       ,i.CreationDate CreationDate
       ,ict.Description Description
--       ,'MONTHLY PAYMENT' Description
       ,'MONTHLY PAYMENT' Type
       ,(i.Usd + ISNULL(i.MonthlyPaymentServiceFee, 0)) Usd
       ,u.Name CreatedByName
       ,ISNULL(i.CardFee, 0) CardFee
      FROM dbo.InsuranceMonthlyPayment i

      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.PaymentType = 'C05'
      OR i.PaymentType = 'C02'
      AND i.CardFee > 0)
      AND i.CreatedInAgencyId = @AgencyId
      AND (@FromCommissions = 1
      AND (CAST(DATEPART(MONTH, i.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, i.CreationDate) AS INT) = @Year)
      OR @FromCommissions = 0
      AND ((CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL))) AND ict.Code = 'C03'

 UNION ALL-- Insurance policyRenewal
      SELECT
        i.CreatedInAgencyId AgencyId
       ,i.CreationDate CreationDate
       ,ict.Description Description
--       ,'MONTHLY PAYMENT' Description
       ,'MONTHLY PAYMENT' Type
       ,(i.Usd + ISNULL(i.MonthlyPaymentServiceFee, 0)) Usd
       ,u.Name CreatedByName
       ,ISNULL(i.CardFee, 0) CardFee
      FROM dbo.InsuranceMonthlyPayment i

      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.PaymentType = 'C05'
      OR i.PaymentType = 'C02'
      AND i.CardFee > 0)
      AND i.CreatedInAgencyId = @AgencyId
      AND (@FromCommissions = 1
      AND (CAST(DATEPART(MONTH, i.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, i.CreationDate) AS INT) = @Year)
      OR @FromCommissions = 0
      AND ((CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL))) AND ict.Code = 'C02'
 
      UNION ALL-- Insurance Registration
      SELECT
        i.CreatedInAgencyId AgencyId
       ,i.CreationDate CreationDate
       ,'REGISTRATION RELEASE (S.O.S)' Description
       ,'REGISTRATION RELEASE (S.O.S)' Type
       ,(i.USD + ISNULL(i.RegistrationReleaseSOSFee, 0)) Usd
       ,u.Name CreatedByName
       ,ISNULL(i.CardFee, 0) CardFee
      FROM dbo.InsuranceRegistration i
      INNER JOIN dbo.Users u
        ON u.UserId = i.CreatedBy
      WHERE (i.PaymentType = 'C05'
      OR i.PaymentType = 'C02'
      AND i.CardFee > 0)
      AND i.CreatedInAgencyId = @AgencyId
      AND (@FromCommissions = 1
      AND (CAST(DATEPART(MONTH, i.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, i.CreationDate) AS INT) = @Year)
      OR @FromCommissions = 0
      AND ((CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)))
    --      AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    --      OR @FromDate IS NULL)
    --      AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    --      OR @ToDate IS NULL)

    ) q



  RETURN;
END;

GO