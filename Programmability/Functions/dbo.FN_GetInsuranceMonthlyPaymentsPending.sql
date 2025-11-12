SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 9/12/2024 8:48 a. m.
-- Database:    developing
-- Description: task 6423 Insurance - Add nuevo campo insurance
-- =============================================
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-15 DJ/6291: Agregar el service type en list QA Monthly payments(PENDING)
-- 2025-02-07 DJ/6335: Agregar Campo URL en la Configuración de Insurance Companies
-- 2025-03-28 LF/6352: Permitir agregar notas a los INSURANCE


CREATE   FUNCTION [dbo].[FN_GetInsuranceMonthlyPaymentsPending] (@UserId INT = NULL, @AgencyId INT = NULL)

RETURNS @result TABLE (
  [InsuranceMonthlyPaymentId] [INT] NOT NULL
 ,[ProviderId] [INT] NOT NULL
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
 ,DOB DATETIME NULL
 ,Description  VARCHAR(20)
 ,[InsuranceCompanyURL] [VARCHAR](400) NULL
 ,[InsuranceConceptTypeId] INT
)
AS


BEGIN


  INSERT INTO @result
    SELECT
      i.[InsuranceMonthlyPaymentId]
     ,ii.[ProviderId]
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
   ,ii.DOB
   ,t.Description
   ,ic.[URL]
   ,ict.InsuranceConceptTypeId
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
    LEFT JOIN dbo.InsurancePaymentType it
      ON it.InsurancePaymentTypeId = i.InsurancePaymentTypeId
    LEFT JOIN dbo.Users uv
      ON uv.UserId = i.ValidatedBy
	  INNER JOIN dbo.InsuranceCommissionType t ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
    LEFT JOIN dbo.InsuranceConceptType ict 
    ON ict.Code = 'C04' 
    WHERE i.MonthlyPaymentStatusId = 1
  AND (i.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND (i.CreatedInAgencyId = @AgencyId
  OR @AgencyId IS NULL)    

  RETURN;

END
GO