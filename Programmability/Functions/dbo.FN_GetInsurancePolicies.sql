SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-10-02 JT/6039: (Add new filter DateTo)
-- 2024-08-28 DJ/6016: Gets insurance policies list

-- =============================================
-- Author:      JF
-- Create date: 7/10/2024 4:39 p. m.
-- Database:    developing
-- Description: task : Validar teléfono cliente
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 23/10/2024 1:28 p. m.
-- Database:    developing
-- Description: task 6116 Ajustes pantallas insurance-daily
-- =============================================

--26-11-2024 JT/6203 : Add news fields @CardFee DECIMAL(18, 2) = NULL, @PaymentType VARCHAR(50) = NULL,
-- 2024-12-08 JF/6243: Insurance - Add nuevo campo insurance
-- 2024-12-27 DJ/6266: Aplicar comisión provider a los insurance - NEW POLICY
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-02-08 DJ/6335: Agregar Campo URL en la Configuración de Insurance Companies
-- 2025-02-27 DJ/6365: Insurance quot
-- 2025-03-05 DJ/6348: Restringir providers INSURANCE luego de pagada la comisión provider

CREATE   FUNCTION [dbo].[FN_GetInsurancePolicies] (@AgencyId INT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL,
@DateTo DATETIME = NULL)



RETURNS @result TABLE (
  [InsurancePolicyId] [INT] NOT NULL
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
 ,ValidatedUSD DECIMAL(18, 2) NULL
 ,PaymentStatusCode VARCHAR(5)
 ,InsurancePaymentTypeCode VARCHAR(5) NULL
 ,ValidatedBy INT NULL
 ,ValidatedByName VARCHAR(70) NULL
 ,ValidatedOn DATETIME NULL
 ,TelIsCheck BIT NULL
 ,[TelephoneSaved] [VARCHAR](10) NOT NULL
 ,CardFee DECIMAL(18, 2) NULL
 ,PaymentType [VARCHAR](10) NOT NULL
 ,TransactionId VARCHAR(36) NULL
 ,MonthlyPaymentUsd DECIMAL(18, 2) NULL
 ,FeeService DECIMAL(18, 2)
 ,DOB DATETIME NULL
 ,CommissionUsd DECIMAL(18,2)
 ,InsuranceCompanyURL VARCHAR(400) NULL
 ,InsuranceQuoteId INT NULL
)
AS


BEGIN


  INSERT INTO @result
    SELECT
      i.[InsurancePolicyId]
     ,i.[ProviderId]
     ,i.[ProviderId] ProviderSavedId
     ,p.Name
     ,i.[InsuranceCompaniesId]
     ,ic.Name
     ,i.[ClientName]
     ,i.[ClientTelephone]
     ,i.[ExpirationDate]
     ,i.[PolicyNumber]
     ,i.[USD]
     ,i.[CreatedBy]
     ,u.Name
     ,i.[CreationDate]
     ,i.[LastUpdatedOn]
     ,i.[LastUpdatedBy]
     ,uu.Name
     ,i.[CreatedInAgencyId]
     ,a.Code + ' - ' + a.Name
     ,i.PolicyTypeId
     ,pt.Description
     ,CASE
        WHEN i.USD > 0 THEN 'CASH'
        ELSE 'CARD CUSTOMER'
      END
     ,i.Cash
     ,CASE
        WHEN i.Cash IS NOT NULL THEN (i.Cash - (i.USD + i.FeeService))
        ELSE NULL
      END
     ,i.ValidatedUSD
     ,po.Code AS PaymentStatusCode
     ,it.Code AS InsurancePaymentTypeCode
     ,i.ValidatedBy
     ,uv.Name AS ValidatedBy
     ,i.ValidatedOn
     ,i.TelIsCheck
     ,i.[ClientTelephone] TelephoneSaved
     ,i.CardFee
     ,i.PaymentType
     ,i.TransactionId
     ,ISNULL(i.MonthlyPaymentUsd,0) AS MonthlyPaymentUsd
	 ,i.FeeService
	 ,i.DOB
	 ,ISNULL(i.CommissionUsd,0) CommissionUsd
	 ,ic.[URL]
	 ,i.InsuranceQuoteId
    FROM [dbo].[InsurancePolicy] i
    INNER JOIN dbo.Providers p
      ON p.ProviderId = i.ProviderId
    INNER JOIN dbo.InsuranceCompanies ic
      ON ic.InsuranceCompaniesId = i.InsuranceCompaniesId
    INNER JOIN dbo.Users u
      ON u.UserId = i.CreatedBy
    INNER JOIN dbo.Users uu
      ON uu.UserId = i.LastUpdatedBy
    INNER JOIN dbo.Agencies a
      ON a.AgencyId = i.CreatedInAgencyId
    INNER JOIN dbo.PolicyType pt
      ON pt.PolicyTypeId = i.PolicyTypeId
    INNER JOIN dbo.InsurancePolicyStatus po
      ON po.InsurancePolicyStatusId = i.PaymentStatusId
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
    OR CAST(i.CreationDate AS DATE) <= CAST(@Date AS DATE)) AND
	i.CreatedByMonthlyPayment = CAST(0 as BIT)


  RETURN;

END
GO