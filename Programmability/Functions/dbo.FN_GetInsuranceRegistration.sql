SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-02 JT/6039: (Add new filter DateTo)

-- 2024-08-31 DJ/6016: Gets insurance insurance registration list
-- =============================================
-- Author:      JF
-- Create date: 7/10/2024 4:39 p. m.
-- Database:    developing
-- Description: task : Validar teléfono cliente
-- =============================================

-- 2024-11-25 DJ/6016: Agregar nuevo tipo de pago(cardpayments) para los insurance del daily
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-03-05 DJ/6348: Restringir providers INSURANCE luego de pagada la comisión provider


CREATE FUNCTION [dbo].[FN_GetInsuranceRegistration] (@AgencyId INT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL,
@DateTo DATETIME = NULL)



RETURNS @result TABLE (
  [InsuranceRegistrationId] [INT] NOT NULL
 ,[ProviderId] [INT] NOT NULL
 ,[ProviderSavedId] [INT] NOT NULL
 ,[ProviderName] [VARCHAR](50) NOT NULL
 ,[ClientName] [VARCHAR](70) NOT NULL
 ,[ClientTelephone] [VARCHAR](10) NOT NULL
 ,[USD] [DECIMAL](18, 2) NOT NULL
 ,[CreatedBy] [INT] NOT NULL
 ,[CreatedByName] [VARCHAR](50) NOT NULL
 ,[CreationDate] [DATETIME] NOT NULL
 ,[LastUpdatedOn] [DATETIME] NOT NULL
 ,[LastUpdatedBy] [INT] NOT NULL
 ,[LastUpdatedByName] [VARCHAR](50) NOT NULL
 ,[CreatedInAgencyId] [INT] NOT NULL
 ,[AgencyName] [VARCHAR](50) NOT NULL
 ,[PaymentTypeName] VARCHAR(15) NOT NULL
 ,[Cash] DECIMAL(18, 2) NULL
 ,[Change] DECIMAL(18, 2) NULL
 ,[RegistrationReleaseSOSFee] DECIMAL(18, 2) NOT NULL
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
 ,[PaymentType] [VARCHAR](50) NOT NULL
 ,CommissionUsd DECIMAL(18,2)
)
AS


BEGIN


  INSERT INTO @result
    SELECT
      i.[InsuranceRegistrationId]
     ,i.[ProviderId]
     ,i.[ProviderId] ProviderSavedId
     ,p.Name
     ,i.[ClientName]
     ,i.[ClientTelephone]
     ,i.[USD]
     ,i.[CreatedBy]
     ,u.Name
     ,i.[CreationDate]
     ,i.[LastUpdatedOn]
     ,i.[LastUpdatedBy]
     ,uu.Name
     ,i.[CreatedInAgencyId]
     ,a.Code + ' - ' + a.Name
      ,CASE
        WHEN i.PaymentType = 'C01' THEN 'CASH'
        WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
        ELSE 'CARD PAYMENT'
     END
     ,i.Cash
     ,CASE
        WHEN i.Cash IS NOT NULL THEN (i.Cash - (i.USD + i.RegistrationReleaseSOSFee))
        ELSE NULL
      END AS Change
     ,i.RegistrationReleaseSOSFee
     ,(i.USD + i.RegistrationReleaseSOSFee + ISNULL(i.CardFee, 0))
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
     ,i.TelIsCheck
     ,i.[ClientTelephone] TelephoneSaved
     ,i.PaymentType
	 ,0 as CommissionUsd
    FROM [dbo].[InsuranceRegistration] i
    INNER JOIN dbo.Providers p
      ON p.ProviderId = i.ProviderId
    INNER JOIN dbo.Users u
      ON u.UserId = i.CreatedBy
    INNER JOIN dbo.Users uu
      ON uu.UserId = i.LastUpdatedBy
    INNER JOIN dbo.Agencies a
      ON a.AgencyId = i.CreatedInAgencyId
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
    OR CAST(i.CreationDate AS DATE) <= CAST(@Date AS DATE))


  RETURN;

END







GO