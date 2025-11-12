SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-02 JT/6039: (Add new filter DateTo)

-- 2024-09-23 DJ/6020: Gets the daily insurance adjusment details
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-02-12 JT/6329: Fix error in calculated adjustment when is paid by ACH

CREATE FUNCTION [dbo].[FN_GetInsuranceDailyAdjustment] (@AgencyId INT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL)

RETURNS @result TABLE (
  [InsurancePolicyId] [INT] NULL
 ,[InsuranceMonthlyPaymeentId] [INT] NULL
 ,[InsuranceRegistrationId] [INT] NULL
 ,[ProviderId] [INT] NOT NULL
 ,[ProviderName] [VARCHAR](50) NOT NULL
 ,[ClientName] [VARCHAR](70) NOT NULL
 ,[CreatedBy] [INT] NOT NULL
 ,[CreatedByName] [VARCHAR](50) NOT NULL
 ,[CreationDate] [DATETIME] NOT NULL
 ,[Concept] [VARCHAR](30) NOT NULL
 ,[CreatedInAgencyId] [INT] NOT NULL
 ,[AgencyName] [VARCHAR](50) NOT NULL
 ,[USD] [DECIMAL](18, 2) NOT NULL
 ,ValidatedUSD DECIMAL(18, 2) NOT NULL
 ,InsuranceCompanyName VARCHAR(50) NULL
 ,ValidatedBy INT NULL
 ,ValidatedByName VARCHAR(70) NULL
 ,ValidatedOn DATETIME NULL
 ,FeeService DECIMAL(18,2)
 ,CardFee DECIMAL(18,2)
 ,CommissionUsd DECIMAL(18,2)
)
AS


BEGIN

  INSERT INTO @result
    SELECT
      f.InsurancePolicyId
     ,NULL
     ,NULL
     ,f.ProviderId
     ,f.ProviderName
     ,f.ClientName
     ,f.ValidatedBy
     ,f.CreatedByName
     ,f.CreationDate
     ,'NEW POLICY'
     ,f.CreatedInAgencyId
     ,f.AgencyName
     ,f.USD
     ,CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(f.InsurancePolicyId, NULL, NULL)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END
     ,f.InsuranceCompanyName
     ,f.ValidatedBy
     ,f.ValidatedByName
     ,f.ValidatedOn
	 ,ISNULL(f.FeeService, 0) FeeService
	 ,ISNULL(f.CardFee, 0) CardFee
	 ,ISNULL(f.CommissionUsd, 0) CommissionUsd
    FROM dbo.FN_GetInsurancePolicies(@AgencyId, @UserId, @Date,@Date) f
    WHERE f.PaymentStatusCode = 'C02'
    AND f.ValidatedOn IS NOT NULL


  -----------------------------------

  INSERT INTO @result
    SELECT
      NULL
     ,f.InsuranceMonthlyPaymentId
     ,NULL
     ,f.ProviderId
     ,f.ProviderName
     ,f.ClientName
     ,f.CreatedBy
     ,f.CreatedByName
     ,f.CreationDate
     ,'MONTHLY PAYMENT'
     ,f.CreatedInAgencyId
     ,f.AgencyName
     ,f.USD
     ,CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(NULL, f.InsuranceMonthlyPaymentId, NULL)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END
     ,f.InsuranceCompanyName
     ,f.ValidatedBy
     ,f.ValidatedByName
     ,f.ValidatedOn
	 ,ISNULL(f.MonthlyPaymentServiceFee, 0) FeeService
	 ,ISNULL(f.CardFee, 0) CardFee
	 ,ISNULL(f.CommissionUsd, 0) CommissionUsd
    FROM dbo.FN_GetInsuranceMonthlyPayments(@AgencyId, @UserId, @Date,@Date) f
    WHERE f.PaymentStatusCode = 'C02'
    AND f.ValidatedOn IS NOT NULL

  ------------------------------

  INSERT INTO @result
    SELECT
      NULL
     ,NULL
     ,f.InsuranceRegistrationId
     ,f.ProviderId
     ,f.ProviderName
     ,f.ClientName
     ,f.CreatedBy
     ,f.CreatedByName
     ,f.CreationDate
     ,'REGISTRATION RELEASE (S.O.S)'
     ,f.CreatedInAgencyId
     ,f.AgencyName
     ,f.USD
     ,CASE
        WHEN f.InsurancePaymentTypeCode = 'C04' THEN dbo.fn_CalculateInsuranceAchUsd(NULL, NULL, f.InsuranceRegistrationId)
        ELSE -ISNULL(f.ValidatedUSD, 0)
      END
     ,NULL
     ,f.ValidatedBy
     ,f.ValidatedByName
     ,f.ValidatedOn
	 ,ISNULL(f.RegistrationReleaseSOSFee, 0) FeeService
	 ,ISNULL(f.CardFee, 0) CardFee
	 ,ISNULL(f.CommissionUsd, 0) CommissionUsd
    FROM dbo.FN_GetInsuranceRegistration(@AgencyId, @UserId, @Date,@Date) f
    WHERE f.PaymentStatusCode = 'C02'
    AND f.ValidatedOn IS NOT NULL




  RETURN;

END
GO