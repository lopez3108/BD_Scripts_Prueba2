SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-311 DJ/6016: Gets insurance monthly payment list
-- 4-12-2024 JT/6241 Fix error with card payment from monthly payment
-- 2025-01-29 JF/6319: INSURANCE - CARD PAYMMENT no está teniendo en cuenta el USD SERVICE de los insurances

CREATE FUNCTION [dbo].[FN_GetInsuranceDailyCardPayments] (@AgencyId INT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL)



RETURNS @Result TABLE (
  [AgencyId] [INT] NOT NULL
 ,[UserId] [INT] NOT NULL
 ,[Date] DATETIME NOT NULL
 ,[CardPayment] DECIMAL(18, 2) NOT NULL
 ,[CardFee] DECIMAL(18, 2) NULL
 ,[Transactions] INT NULL
)
AS


BEGIN

  DECLARE @newPolicyCard DECIMAL(18, 2)
         ,@newPolicyFee DECIMAL(18, 2)
         ,@monthlyCard DECIMAL(18, 2)
         ,@monthlyFee DECIMAL(18, 2)
         ,@registrationCard DECIMAL(18, 2)
         ,@registrationFee DECIMAL(18, 2)
         ,@cardPayment DECIMAL(18, 2)
         ,@cardPaymentFee DECIMAL(18, 2)
         ,@tranNewPolicy INT
         ,@tranMonth INT
         ,@tranReg INT
         ,@tran INT

  SET @monthlyCard = ISNULL((SELECT
      SUM(m.USD + m.MonthlyPaymentServiceFee)
    FROM dbo.InsuranceMonthlyPayment m
    INNER JOIN dbo.InsurancePolicy i
      ON i.InsurancePolicyId = m.InsurancePolicyId
 WHERE m.CardFee IS NOT NULL
    AND m.CardFee > 0
    AND (@AgencyId IS NULL
    OR m.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR m.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(m.CreationDate AS DATE)))
  , 0)

  SET @monthlyFee = ISNULL((SELECT
      SUM(m.CardFee)
    FROM dbo.InsuranceMonthlyPayment m
    INNER JOIN dbo.InsurancePolicy i
      ON i.InsurancePolicyId = m.InsurancePolicyId
 WHERE m.CardFee IS NOT NULL
    AND m.CardFee > 0
    AND (@AgencyId IS NULL
    OR m.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR m.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(m.CreationDate AS DATE)))
  , 0)

  SET @tranMonth = ISNULL((SELECT
      COUNT(*)
    FROM dbo.InsuranceMonthlyPayment m
    INNER JOIN dbo.InsurancePolicy i
      ON i.InsurancePolicyId = m.InsurancePolicyId
    WHERE m.CardFee IS NOT NULL
    AND m.CardFee > 0
    AND (@AgencyId IS NULL
    OR m.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR m.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(m.CreationDate AS DATE)))
  , 0)

  SET @registrationCard = ISNULL((SELECT
      SUM(r.USD + r.RegistrationReleaseSOSFee)
    FROM dbo.InsuranceRegistration r
    WHERE r.CardFee IS NOT NULL
    AND r.CardFee > 0
    AND (@AgencyId IS NULL
    OR r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)

  SET @registrationFee = ISNULL((SELECT
      SUM(r.CardFee)
    FROM dbo.InsuranceRegistration r
    WHERE r.CardFee IS NOT NULL
    AND (@AgencyId IS NULL
    OR r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)

  SET @tranReg = ISNULL((SELECT
      COUNT(*)
    FROM dbo.InsuranceRegistration r
    WHERE r.CardFee IS NOT NULL
    AND (@AgencyId IS NULL
    OR r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)






  SET @newPolicyCard = ISNULL((SELECT
      SUM(r.USD + r.FeeService)
    FROM dbo.InsurancePolicy r
    WHERE r.CardFee IS NOT NULL
    AND r.CardFee > 0
    AND (r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)

  SET @newPolicyFee = ISNULL((SELECT
      SUM(r.CardFee)
    FROM dbo.InsurancePolicy r
    WHERE r.CardFee IS NOT NULL
    AND r.CardFee > 0
    AND (r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)

  SET @tranNewPolicy = ISNULL((SELECT
      COUNT(*)
    FROM dbo.InsurancePolicy r
    WHERE r.CardFee IS NOT NULL
    AND r.CardFee > 0
    AND (r.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR r.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(@Date AS DATE) = CAST(r.CreationDate AS DATE)))
  , 0)


  SET @cardPayment = (@monthlyCard + @registrationCard + @newPolicyCard)
  SET @cardPaymentFee = (@monthlyFee + @registrationFee + @newPolicyFee)
  SET @tran = (@tranMonth + @tranReg + @tranNewPolicy)



  INSERT INTO @Result
    SELECT
      @AgencyId
     ,@UserId
     ,@Date
     ,@cardPayment
     ,@cardPaymentFee
     ,@tran

  RETURN;

END




GO