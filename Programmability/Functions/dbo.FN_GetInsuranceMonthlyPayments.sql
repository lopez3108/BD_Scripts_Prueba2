SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-02 JT/6039: (Add new filter DateTo)
-- 2024-08-311 DJ/6016: Gets insurance monthly payment list
-- 2024-10-07 JF/6116: Validar teléfono cliente
-- 2024-10-23 DJ/6116: Ajustes pantallas insurance-daily
-- 2024-11-25 DJ/6016: Agregar nuevo tipo de pago(cardpayments) para los insurance del daily
-- 2024-12-30 DJ/6261: Aplicar comisión provider a los insurance - MONTHLY PAYMENTS
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-02-08 DJ/6335: Agregar Campo URL en la Configuración de Insurance Companies
-- 2025-03-05 DJ/6348: Restringir providers INSURANCE luego de pagada la comisión provider
-- 2025-08-14 JF/6719: Error al calcular el pago de las commissiones de los cajeros modulo insurance


CREATE FUNCTION [dbo].[FN_GetInsuranceMonthlyPayments] (@AgencyId INT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL,
@DateTo DATETIME = NULL)

RETURNS @result TABLE (
  [InsuranceMonthlyPaymentId] [INT] NOT NULL
 ,[ProviderId] [INT] NOT NULL
 ,[ProviderSavedId] [INT] NOT NULL
 ,[ProviderName] [VARCHAR](50) NOT NULL
 ,[InsuranceCompaniesId] [INT] NOT NULL
 ,[InsuranceCompanyName] [VARCHAR](50) NOT NULL
 ,[ClientName] [VARCHAR](70) NOT NULL
 ,[ClientTelephone] [VARCHAR](10) NOT NULL
 ,[ExpirationDate] [DATETIME] NOT NULL
 ,[PolicyNumber] [VARCHAR](20) NOT NULL
 ,[USD] [DECIMAL](18, 2) NOT NULL
 ,[CreatedBy] [INT] NOT NULL
 ,[CreatedByName] [VARCHAR](50) NOT NULL
 ,[CreationDate] [DATETIME] NOT NULL
 ,[LastUpdatedOn] [DATETIME] NOT NULL
 ,[LastUpdatedBy] [INT] NOT NULL
 ,[LastUpdatedByName] [VARCHAR](50) NOT NULL
 ,[CreatedInAgencyId] [INT] NOT NULL
 ,[AgencyName] [VARCHAR](50) NOT NULL
 ,[PolicyTypeId] INT NOT NULL
 ,[PolicyTypeName] VARCHAR(50) NOT NULL
 ,[PaymentTypeName] VARCHAR(15) NOT NULL
 ,[Cash] DECIMAL(18, 2) NULL
 ,[Change] DECIMAL(18, 2) NULL
 ,[MonthlyPaymentServiceFee] DECIMAL(18, 2) NOT NULL
 ,[Total] DECIMAL(18, 2) NOT NULL
 ,[CardPayment] BIT NOT NULL
 ,[CardFee] DECIMAL(18, 2) NULL
 ,ValidatedUSD DECIMAL(18, 2) NULL
 ,PaymentStatusCode VARCHAR(5)
 ,InsurancePaymentTypeCode VARCHAR(5) NULL
 ,ValidatedBy INT NULL
 ,ValidatedByName VARCHAR(70) NULL
 ,ValidatedOn DATETIME NULL
 ,TelIsCheck BIT NULL
 ,[TelephoneSaved] [VARCHAR](10) NOT NULL
 ,[InsurancePolicyId] INT
 ,[CreatedInsurancePolicyId] INT NULL
 ,[PaymentType] [VARCHAR](50) NOT NULL
 ,TransactionId VARCHAR(36) NULL
 ,InsuranceCommissionTypeId INT
 ,InsuranceCommissionTypeIdSaved INT
  ,Description VARCHAR(20)
  ,Code VARCHAR(4)
  ,DOB DATETIME NULL
  ,CommissionUsd DECIMAL(18,2)
  ,InsuranceCompanyURL VARCHAR(400) NULL
)
AS


BEGIN


  INSERT INTO @result
    SELECT
      i.[InsuranceMonthlyPaymentId]
     ,ii.[ProviderId]
     ,ii.[ProviderId] ProviderSavedId
     ,p.Name
     ,ii.[InsuranceCompaniesId]
     ,ic.Name
     ,ii.[ClientName]
     ,ii.[ClientTelephone]
     ,ii.[ExpirationDate]
     ,ii.[PolicyNumber]
     ,i.[USD]
     ,i.[CreatedBy]
     ,u.Name
     ,i.[CreationDate]
     ,i.[LastUpdatedOn]
     ,i.[LastUpdatedBy]
     ,uu.Name
     ,i.[CreatedInAgencyId]
     ,a.Code + ' - ' + a.Name
     ,ii.PolicyTypeId
     ,pt.Description
     ,CASE
        WHEN i.PaymentType = 'C01' THEN 'CASH'
        WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
        ELSE 'CARD PAYMENT'
     END

     ,i.Cash
     ,CASE
        WHEN i.Cash IS NOT NULL THEN (i.Cash - (i.USD + i.MonthlyPaymentServiceFee))
        ELSE NULL
      END AS Change
     ,i.MonthlyPaymentServiceFee
     ,(i.USD + i.MonthlyPaymentServiceFee + ISNULL(i.CardFee, 0))
     ,CASE
        WHEN i.CardFee IS NOT NULL AND i.PaymentType = 'C02' THEN CAST(1 AS BIT)
         WHEN i.CardFee IS NOT NULL  AND i.PaymentType = 'C05' THEN CAST(0 AS BIT)
        ELSE CAST(0 AS BIT)
      END
     ,i.CardFee
     ,i.ValidatedUSD
     ,po.Code AS PaymentStatusCode
     ,it.Code AS InsurancePaymentTypeCode
     ,i.ValidatedBy
     ,uv.Name AS ValidatedBy
     ,i.ValidatedOn
     ,ii.TelIsCheck
     ,ii.[ClientTelephone] TelephoneSaved
	 ,i.InsurancePolicyId
	 ,i.CreatedInsurancePolicyId
   ,i.PaymentType
   ,i.TransactionId
   ,i.InsuranceCommissionTypeId
   ,i.InsuranceCommissionTypeId InsuranceCommissionTypeIdSaved
   ,cx.Description
   ,cx.Code
   ,ii.DOB
   ,ISNULL(i.CommissionUsd, 0) CommissionUsd
   ,ic.[URL]
    FROM [dbo].[InsuranceMonthlyPayment] i
	INNER JOIN dbo.InsurancePolicy ii ON ii.InsurancePolicyId = i.InsurancePolicyId
    INNER JOIN dbo.Providers p
      ON p.ProviderId = ii.ProviderId
    INNER JOIN dbo.InsuranceCompanies ic
      ON ic.InsuranceCompaniesId = ii.InsuranceCompaniesId
    INNER JOIN dbo.Users u
      ON u.UserId = i.CreatedBy
    INNER JOIN dbo.Users uu
      ON uu.UserId = i.LastUpdatedBy
    INNER JOIN dbo.Agencies a
      ON a.AgencyId = i.CreatedInAgencyId
    INNER JOIN dbo.PolicyType pt
      ON pt.PolicyTypeId = ii.PolicyTypeId
    INNER JOIN dbo.InsurancePolicyStatus po
      ON po.InsurancePolicyStatusId = i.PaymentStatusId
	  INNER JOIN dbo.InsuranceCommissionType cx 
	  ON cx.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
    LEFT JOIN dbo.InsurancePaymentType it
      ON it.InsurancePaymentTypeId = i.InsurancePaymentTypeId
    LEFT JOIN dbo.Users uv
      ON uv.UserId = i.ValidatedBy
    WHERE (@AgencyId IS NULL
    OR i.CreatedInAgencyId = @AgencyId)
    AND (@UserId IS NULL
    OR i.CreatedBy = @UserId)
    AND (@Date IS NULL
    OR CAST(i.CreationDate AS DATE) >= CAST(@Date AS DATE))
    AND (@DateTo IS NULL
    OR CAST(i.CreationDate AS DATE) <= CAST(@Date AS DATE))


  RETURN;

END










GO