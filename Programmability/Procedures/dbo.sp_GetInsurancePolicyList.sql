SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-09-10 CB/6019: Gets policy history list
-- =============================================
-- Author:      JF
-- Create date: 10/10/2024 12:21 p. m.
-- Database:    developing
-- Description: task 6075 Validar teléfono cliente
-- =============================================

-- 2024-11-08 JF/6177: Orden búsqueda grid insurance
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-15 JF/6287: Ajustes generales INSURANCE
-- 2025-01-15 DJ/6260: Adicionar comisiones al momento de ajustar un insurance
-- 2025-01-23 JF/6303: Insurance - Filtros INSURANCE trae registros NULL
-- 2025-02-10 JF/6339: Filtros módulo insurance no funcionan correctamente
-- 2025-02-12 DJ/6345: Pagar automáticamente movimiento hechos con card customer
-- 2025-02-12 JF/6359: Ajustes en los Filtros del Módulo Insurance
-- 2025-02-27 DJ/6365: Insurance quote
-- 2025-03-28 LF/6352: Permitir agregar notas a los INSURANCE
-- 2025-04-10 JF/6452: Agregar un filtro de AGENCY
-- 2025-04-28 CB/6481: Agregar campos VIN a los Insurance policy
-- 2025-05-13 DJ/6505: No se está mostrando el tipo de pago correcto para los insurance

CREATE PROCEDURE [dbo].[sp_GetInsurancePolicyList] @ClientName VARCHAR(50) = NULL,
@ClientTelephone VARCHAR(10) = NULL,
@PolicyNumber VARCHAR(20) = NULL,
@InsurancePolicyId INT = NULL,
@InsuranceCompaniesId INT = NULL,
@PaymentStatusId INT = NULL,
@CommissionStatusId INT = NULL,
@ShowMonthlyPayments BIT = 0,
@ShowExistentPolicies BIT = 0,
@InsuranceTypeIds VARCHAR(100) = NULL,
@FromDate DATE = NULL,
@ToDate DATE = NULL,
@ProviderId INT = NULL,
@SelectedAgencyIds VARCHAR(500) = NULL
AS

BEGIN

  DECLARE @newPolicySelected BIT = 0;
  DECLARE @monthlyPaymentSelected BIT = 0;
  DECLARE @sosSelected BIT = 0;
  DECLARE @endorsementSelected BIT = 0;  -- Default: FALSE
  DECLARE @policyRenewalSelected BIT = 0;  -- Default: FALSE

  IF CHARINDEX('1', @InsuranceTypeIds) > 0
    SET @newPolicySelected = 1;
  IF CHARINDEX('2', @InsuranceTypeIds) > 0
    SET @monthlyPaymentSelected = 1;
  IF CHARINDEX('3', @InsuranceTypeIds) > 0
    SET @sosSelected = 1;
  IF CHARINDEX('4', @InsuranceTypeIds) > 0
    SET @endorsementSelected = 1;  -- TRUE
  IF CHARINDEX('5', @InsuranceTypeIds) > 0
    SET @policyRenewalSelected = 1;  -- TRUE

  DECLARE @paymentStatusPaidCode VARCHAR(4)
  SET @paymentStatusPaidCode = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM InsurancePolicyStatus i
    WHERE i.Code = 'C02') --PAID

  SELECT
    i.[InsurancePolicyId]
   ,NULL AS InsuranceMonthlyPaymentId
   ,NULL AS InsuranceRegistrationId
   ,i.[ProviderId]
   ,i.[InsuranceCompaniesId]
   ,i.[ClientName]
   ,i.[ClientTelephone]
   ,i.[ExpirationDate]
   ,i.[PolicyNumber]
   ,i.[USD]
   ,i.[CreatedBy]
   ,i.[CreationDate]
   ,i.[LastUpdatedOn]
   ,i.[LastUpdatedBy]
   ,i.[CreatedInAgencyId]
   ,i.[PolicyTypeId]
   ,i.[Cash]
   ,i.[PaymentStatusId]
   ,i.[CommissionStatusId]
   ,i.[TelIsCheck]
   ,i.[ClientTelephone] TelephoneSaved
   ,u.Name AS CreatedByName
   ,ul.Name AS LastUpdatedByName
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,s.Description AS PaymentStatus
   ,s.Description AS CommissionStatus
   ,'NEW POLICY' AS Concept
   ,'C01' AS TypeCode
   ,ict.InsuranceConceptTypeId
   ,p.Name AS Provider
   ,ic.Name AS InsuranceCompany
   ,pp.Description AS PolicyType
   ,CASE
      WHEN i.PaymentType = 'C01' THEN 'CASH'
	   WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
	   WHEN i.PaymentType = 'C05' THEN 'CARD PAYMENT'
    END AS PaymentType
   ,s.Code AS PaymentStatusCode
   ,s.Description AS PaymentStatusDescription
   ,sc.Code AS CommissionStatusCode
   ,sc.Description AS CommissionStatusDescription
   ,CASE
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C04' THEN [dbo].[fn_CalculateInsuranceAchUsd](i.InsurancePolicyId, NULL, NULL)
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C01' THEN i.ValidatedUSD
      ELSE NULL
    END AS ValidatedUSD
   ,i.ValidatedOn
   ,i.ValidatedBy
   ,uv.Name AS ValidatedByName
   ,av.AgencyId AS ValidatedAgencyId
   ,av.Code + ' - ' + av.Name AS ValidatedAgencyCodeName
   ,i.InsurancePaymentTypeId
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN 'CARD CUSTOMER'
      ELSE ipt.Description
    END AS InsurancePaymentTypeDescription
   ,ipt.Code AS InsurancePaymentTypeCode
   ,c.CashierId
   ,CASE
      WHEN i.TransactionId IS NULL OR
        i.TransactionId = '' THEN '-'
      ELSE i.TransactionId
    END AS TransactionId
   ,'-' AS StatusInformation
   ,ISNULL(i.MonthlyPaymentUsd, 0) AS MonthlyPaymentUsd
   ,[dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) AS Adjustment
   ,i.DOB
   ,(ISNULL(i.USD, 0) + ISNULL(i.FeeService, 0) + ISNULL(i.CardFee, 0)) AS TotalToPay
   ,ISNULL(i.FeeService, 0) FeeService
   ,ISNULL(i.CardFee, 0) CardFee
   ,ISNULL(i.CardFee, 0) * -1 CardFeeNegative
   ,ISNULL(i.CommissionUsd, 0) CommissionUsd
   ,(ISNULL(i.FeeService, 0) * -1) FeeServiceNegative
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ValidatedByCashier
    ,i.InsuranceQuoteId
	,CASE WHEN EXISTS(SELECT * FROM dbo.InsurancePolicyVIN v WHERE v.InsurancePolicyId = i.InsurancePolicyId) THEN
	(SELECT TOP 1 v.VINNumber FROM dbo.InsurancePolicyVIN v WHERE v.InsurancePolicyId = i.InsurancePolicyId ORDER BY InsurancePolicyVINId ASC) ELSE
	NULL END AS VINNumber
  FROM [dbo].[InsurancePolicy] i
  INNER JOIN dbo.InsuranceCompanies ic
    ON ic.InsuranceCompaniesId = i.InsuranceCompaniesId
  INNER JOIN dbo.Providers p
    ON p.ProviderId = i.ProviderId
  INNER JOIN dbo.Users u
    ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users ul
    ON ul.UserId = i.LastUpdatedBy
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = i.CreatedInAgencyId
  INNER JOIN dbo.InsurancePolicyStatus s
    ON s.InsurancePolicyStatusId = i.PaymentStatusId
  INNER JOIN dbo.InsurancePolicyStatus sc
    ON sc.InsurancePolicyStatusId = i.CommissionStatusId
  INNER JOIN dbo.PolicyType pp
    ON pp.PolicyTypeId = i.PolicyTypeId
  INNER JOIN dbo.Cashiers c
    ON c.UserId = i.CreatedBy
  LEFT JOIN dbo.Users uv
    ON uv.UserId = i.ValidatedBy
  LEFT JOIN dbo.Agencies av
    ON av.AgencyId = i.ValidatedAgencyId
  LEFT JOIN dbo.InsurancePaymentType ipt
    ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
  LEFT JOIN dbo.InsuranceConceptType ict 
    ON ict.Code = 'C01'  -- Se agrega el JOIN aquí
  WHERE (@ClientName IS NULL
  OR i.ClientName LIKE '%' + @ClientName + '%')
  AND (@ClientTelephone IS NULL
  OR i.ClientTelephone = @ClientTelephone)
  AND (@PolicyNumber IS NULL
  OR i.PolicyNumber = @PolicyNumber)
  AND (@InsuranceCompaniesId IS NULL
  OR i.InsuranceCompaniesId = @InsuranceCompaniesId)
  AND (@PaymentStatusId IS NULL
  OR i.PaymentStatusId = @PaymentStatusId)
  AND (@CommissionStatusId IS NULL
  OR i.CommissionStatusId = @CommissionStatusId)
  AND ((@ShowExistentPolicies = CAST(0 AS BIT)
  AND i.CreatedByMonthlyPayment = CAST(0 AS BIT))
  OR (@ShowExistentPolicies = CAST(1 AS BIT)))
  AND (@newPolicySelected = CAST(1 AS BIT)
  OR @InsuranceTypeIds IS NULL)
  AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND (@ProviderId IS NULL
  OR i.ProviderId = @ProviderId)
    AND (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@SelectedAgencyIds))
  OR @SelectedAgencyIds IS NULL)


  UNION ALL

  SELECT
    NULL AS InsurancePolicyId
   ,NULL AS InsuranceMonthlyPaymentId
   ,i.[InsuranceRegistrationId]
   ,i.[ProviderId]
   ,NULL
   ,i.[ClientName]
   ,i.[ClientTelephone]
   ,NULL
   ,NULL
   ,i.[USD]
   ,i.[CreatedBy]
   ,i.[CreationDate]
   ,i.[LastUpdatedOn]
   ,i.[LastUpdatedBy]
   ,i.[CreatedInAgencyId]
   ,NULL
   ,i.[Cash]
   ,i.[PaymentStatusId]
   ,i.[CommissionStatusId]
   ,i.[TelIsCheck]
   ,i.[ClientTelephone] TelephoneSaved
   ,u.Name AS CreatedByName
   ,ul.Name AS LastUpdatedByName
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,s.Description AS PaymentStatus
   ,s.Description AS CommissionStatus
   ,'REGISTRATION RELEASE (S.O.S)' AS Concept
   ,'C03' AS TypeCode
   ,ict.InsuranceConceptTypeId
   ,p.Name AS Provider
   ,NULL
   ,NULL AS PolicyType
    ,CASE
      WHEN i.PaymentType = 'C01' THEN 'CASH'
	   WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
	   WHEN i.PaymentType = 'C05' THEN 'CARD PAYMENT'
    END AS PaymentType
   ,s.Code AS PaymentStatusCode
   ,s.Description AS PaymentStatusDescription
   ,sc.Code AS CommissionStatusCode
   ,sc.Description AS CommissionStatusDescription
   ,CASE
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C04' THEN [dbo].[fn_CalculateInsuranceAchUsd](NULL, NULL, i.InsuranceRegistrationId)
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C01' THEN i.ValidatedUSD
      ELSE NULL
    END AS ValidatedUSD
   ,i.ValidatedOn
   ,i.ValidatedBy
   ,uv.Name AS ValidatedByName
   ,av.AgencyId AS ValidatedAgencyId
   ,av.Code + ' - ' + av.Name AS ValidatedAgencyCodeName
   ,i.InsurancePaymentTypeId
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN 'CARD CUSTOMER'
      ELSE ipt.Description
    END AS InsurancePaymentTypeDescription
   ,ipt.Code AS InsurancePaymentTypeCode
   ,c.CashierId
   ,'-' TransactionId
   ,'-' AS StatusInformation
   ,0 AS MonthlyPaymentUsd
   ,[dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) AS Adjustment
   ,NULL
   ,(ISNULL(i.USD, 0) + ISNULL(i.RegistrationReleaseSOSFee, 0) + ISNULL(i.CardFee, 0)) AS TotalToPay
   ,ISNULL(i.RegistrationReleaseSOSFee, 0) FeeService
   ,ISNULL(i.CardFee, 0) CardFee
   ,ISNULL(i.CardFee, 0) * -1 CardFeeNegative
   ,0 CommissionUsd
   ,(ISNULL(i.RegistrationReleaseSOSFee, 0) * -1) FeeServiceNegative
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ValidatedByCashier
    ,NULL
	,NULL
  FROM [dbo].[InsuranceRegistration] i
  INNER JOIN dbo.Providers p
    ON p.ProviderId = i.ProviderId
  INNER JOIN dbo.Users u
    ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users ul
    ON ul.UserId = i.LastUpdatedBy
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = i.CreatedInAgencyId
  INNER JOIN dbo.InsurancePolicyStatus s
    ON s.InsurancePolicyStatusId = i.PaymentStatusId
  INNER JOIN dbo.InsurancePolicyStatus sc
    ON sc.InsurancePolicyStatusId = i.CommissionStatusId
  INNER JOIN dbo.Cashiers c
    ON c.UserId = i.CreatedBy
  LEFT JOIN dbo.Users uv
    ON uv.UserId = i.ValidatedBy
  LEFT JOIN dbo.Agencies av
    ON av.AgencyId = i.ValidatedAgencyId
  LEFT JOIN dbo.InsurancePaymentType ipt
    ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
  LEFT JOIN dbo.InsuranceConceptType ict 
    ON ict.Code = 'C05'  -- Se agrega el JOIN aquí
  WHERE (@ClientName IS NULL
  OR i.ClientName LIKE '%' + @ClientName + '%')
  AND (@ClientTelephone IS NULL
  OR i.ClientTelephone = @ClientTelephone)
  AND (@PaymentStatusId IS NULL
  OR i.PaymentStatusId = @PaymentStatusId)
  AND (@CommissionStatusId IS NULL
  OR i.CommissionStatusId = @CommissionStatusId)
  AND (@PolicyNumber IS NULL)
  AND (@sosSelected = CAST(1 AS BIT)
  OR @InsuranceTypeIds IS NULL)
  AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND @InsuranceCompaniesId IS NULL
  AND (@ProviderId IS NULL
  OR i.ProviderId = @ProviderId)
      AND (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@SelectedAgencyIds))
  OR @SelectedAgencyIds IS NULL)

  UNION ALL

  -- Monthly payments

  SELECT
    NULL AS InsurancePolicyId
   ,i.[InsuranceMonthlyPaymentId]
   ,NULL AS InsuranceRegistrationId
   ,ii.[ProviderId]
   ,ii.[InsuranceCompaniesId]
   ,ii.[ClientName]
   ,ii.[ClientTelephone]
   ,ii.[ExpirationDate]
   ,ii.[PolicyNumber]
   ,i.[USD]
   ,i.[CreatedBy]
   ,i.[CreationDate]
   ,i.[LastUpdatedOn]
   ,i.[LastUpdatedBy]
   ,i.[CreatedInAgencyId]
   ,ii.[PolicyTypeId]
   ,i.[Cash]
   ,i.[PaymentStatusId]
   ,i.[CommissionStatusId]
   ,i.[TelIsCheck]
   ,ii.[ClientTelephone] TelephoneSaved
   ,u.Name AS CreatedByName
   ,ul.Name AS LastUpdatedByName
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,s.Description AS PaymentStatus
   ,s.Description AS CommissionStatus
   ,ict.Description AS Concept
    --	  ,'MONTHLY PAYMENT' as Concept
   ,'C02' AS TypeCode
   ,icty.InsuranceConceptTypeId
   ,p.Name AS Provider
   ,ic.Name AS InsuranceCompany
   ,pp.Description AS PolicyType
    ,CASE
      WHEN i.PaymentType = 'C01' THEN 'CASH'
	   WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
	   WHEN i.PaymentType = 'C05' THEN 'CARD PAYMENT'
    END AS PaymentType
   ,s.Code AS PaymentStatusCode
   ,s.Description AS PaymentStatusDescription
   ,sc.Code AS CommissionStatusCode
   ,sc.Description AS CommissionStatusDescription
   ,CASE
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C04' THEN [dbo].[fn_CalculateInsuranceAchUsd](NULL, i.InsuranceMonthlyPaymentId, NULL)
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C01' THEN i.ValidatedUSD
      ELSE NULL
    END AS ValidatedUSD
   ,i.ValidatedOn
   ,i.ValidatedBy
   ,uv.Name AS ValidatedByName
   ,av.AgencyId AS ValidatedAgencyId
   ,av.Code + ' - ' + av.Name AS ValidatedAgencyCodeName
   ,i.InsurancePaymentTypeId
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN 'CARD CUSTOMER'
      ELSE ipt.Description
    END AS InsurancePaymentTypeDescription
   ,ipt.Code AS InsurancePaymentTypeCode
   ,c.CashierId
   ,CASE
      WHEN i.TransactionId IS NULL OR
        i.TransactionId = '' THEN '-'
      ELSE i.TransactionId
    END AS TransactionId
   ,CASE
      WHEN mps.Description IS NULL OR
        mps.Description = '' THEN '-'
      ELSE mps.Description
    END AS StatusInformation
   ,0 AS MonthlyPaymentUsd
   ,
    --    mps.Description AS StatusInformation,
    [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) AS Adjustment
   ,ii.DOB
   ,(ISNULL(i.USD, 0) + ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CardFee, 0)) AS TotalToPay
   ,ISNULL(i.MonthlyPaymentServiceFee, 0) FeeService
   ,ISNULL(i.CardFee, 0) CardFee
   ,ISNULL(i.CardFee, 0) * -1 CardFeeNegative
   ,ISNULL(i.CommissionUsd, 0) CommissionUsd
   ,(ISNULL(i.MonthlyPaymentServiceFee, 0) * -1) FeeServiceNegative
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ValidatedByCashier
    ,NULL
	,NULL
  FROM [dbo].[InsuranceMonthlyPayment] i
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = i.InsurancePolicyId
  INNER JOIN dbo.InsuranceCompanies ic
    ON ic.InsuranceCompaniesId = ii.InsuranceCompaniesId
  INNER JOIN dbo.Providers p
    ON p.ProviderId = ii.ProviderId
  INNER JOIN dbo.Users u
    ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users ul
    ON ul.UserId = i.LastUpdatedBy
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = i.CreatedInAgencyId
  INNER JOIN dbo.InsurancePolicyStatus s
    ON s.InsurancePolicyStatusId = i.PaymentStatusId
  INNER JOIN dbo.InsurancePolicyStatus sc
    ON sc.InsurancePolicyStatusId = i.CommissionStatusId
  INNER JOIN dbo.Cashiers c
    ON c.UserId = i.CreatedBy
  INNER JOIN dbo.PolicyType pp
    ON pp.PolicyTypeId = ii.PolicyTypeId
  LEFT JOIN MonthlyPaymentStatus mps
    ON i.MonthlyPaymentStatusId = mps.MonthlyPaymentStatusId
  INNER JOIN InsuranceCommissionType ict
    ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  LEFT JOIN dbo.Users uv
    ON uv.UserId = i.ValidatedBy
  LEFT JOIN dbo.Agencies av
    ON av.AgencyId = i.ValidatedAgencyId
  LEFT JOIN dbo.InsurancePaymentType ipt
    ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
     INNER JOIN dbo.InsurancePolicy ip
        ON ip.InsurancePolicyId = i.InsurancePolicyId
 LEFT JOIN dbo.InsuranceConceptType icty 
    ON icty.Code = 'C04'  -- Se agrega el JOIN aquí
  WHERE (@ClientName IS NULL
  OR ii.ClientName LIKE '%' + @ClientName + '%')
  AND (@ClientTelephone IS NULL
  OR ii.ClientTelephone = @ClientTelephone)
  AND (@PolicyNumber IS NULL
  OR ii.PolicyNumber = @PolicyNumber)
  AND (@InsuranceCompaniesId IS NULL
  OR ii.InsuranceCompaniesId = @InsuranceCompaniesId)
  AND (@PaymentStatusId IS NULL
  OR i.PaymentStatusId = @PaymentStatusId)
  AND (@CommissionStatusId IS NULL
  OR i.CommissionStatusId = @CommissionStatusId)
  AND (i.InsurancePolicyId = @InsurancePolicyId
  OR @InsurancePolicyId IS NULL)
  AND (@ShowMonthlyPayments = CAST(1 AS BIT))
  AND ((@monthlyPaymentSelected = CAST(1 AS BIT)
  AND ict.Code = 'C04')
  OR @InsuranceTypeIds IS NULL)
  AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND (@ProviderId IS NULL
  OR ip.ProviderId = @ProviderId)
      AND (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@SelectedAgencyIds))
  OR @SelectedAgencyIds IS NULL)


  UNION ALL

  -- endorsement

  SELECT
    NULL AS InsurancePolicyId
   ,i.[InsuranceMonthlyPaymentId]
   ,NULL AS InsuranceRegistrationId
   ,ii.[ProviderId]
   ,ii.[InsuranceCompaniesId]
   ,ii.[ClientName]
   ,ii.[ClientTelephone]
   ,ii.[ExpirationDate]
   ,ii.[PolicyNumber]
   ,i.[USD]
   ,i.[CreatedBy]
   ,i.[CreationDate]
   ,i.[LastUpdatedOn]
   ,i.[LastUpdatedBy]
   ,i.[CreatedInAgencyId]
   ,ii.[PolicyTypeId]
   ,i.[Cash]
   ,i.[PaymentStatusId]
   ,i.[CommissionStatusId]
   ,i.[TelIsCheck]
   ,ii.[ClientTelephone] TelephoneSaved
   ,u.Name AS CreatedByName
   ,ul.Name AS LastUpdatedByName
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,s.Description AS PaymentStatus
   ,s.Description AS CommissionStatus
   ,ict.Description AS Concept
    --	  ,'MONTHLY PAYMENT' as Concept
   ,'C02' AS TypeCode
   ,icty.InsuranceConceptTypeId
   ,p.Name AS Provider
   ,ic.Name AS InsuranceCompany
   ,pp.Description AS PolicyType
    ,CASE
      WHEN i.PaymentType = 'C01' THEN 'CASH'
	   WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
	   WHEN i.PaymentType = 'C05' THEN 'CARD PAYMENT'
    END AS PaymentType
   ,s.Code AS PaymentStatusCode
   ,s.Description AS PaymentStatusDescription
   ,sc.Code AS CommissionStatusCode
   ,sc.Description AS CommissionStatusDescription
   ,CASE
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C04' THEN [dbo].[fn_CalculateInsuranceAchUsd](NULL, i.InsuranceMonthlyPaymentId, NULL)
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C01' THEN i.ValidatedUSD
      ELSE NULL
    END AS ValidatedUSD
   ,i.ValidatedOn
   ,i.ValidatedBy
   ,uv.Name AS ValidatedByName
   ,av.AgencyId AS ValidatedAgencyId
   ,av.Code + ' - ' + av.Name AS ValidatedAgencyCodeName
   ,i.InsurancePaymentTypeId
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN 'CARD CUSTOMER'
      ELSE ipt.Description
    END AS InsurancePaymentTypeDescription
   ,ipt.Code AS InsurancePaymentTypeCode
   ,c.CashierId
   ,CASE
      WHEN i.TransactionId IS NULL OR
        i.TransactionId = '' THEN '-'
      ELSE i.TransactionId
    END AS TransactionId
   ,CASE
      WHEN mps.Description IS NULL OR
        mps.Description = '' THEN '-'
      ELSE mps.Description
    END AS StatusInformation
   ,0 AS MonthlyPaymentUsd
   ,
    --    mps.Description AS StatusInformation,
    [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) AS Adjustment
   ,ii.DOB
   ,(ISNULL(i.USD, 0) + ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CardFee, 0)) AS TotalToPay
   ,ISNULL(i.MonthlyPaymentServiceFee, 0) FeeService
   ,ISNULL(i.CardFee, 0) CardFee
   ,ISNULL(i.CardFee, 0) * -1 CardFeeNegative
   ,ISNULL(i.CommissionUsd, 0) CommissionUsd
   ,(ISNULL(i.MonthlyPaymentServiceFee, 0) * -1) FeeServiceNegative
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ValidatedByCashier
    ,NULL
	,NULL
  FROM [dbo].[InsuranceMonthlyPayment] i
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = i.InsurancePolicyId
  INNER JOIN dbo.InsuranceCompanies ic
    ON ic.InsuranceCompaniesId = ii.InsuranceCompaniesId
  INNER JOIN dbo.Providers p
    ON p.ProviderId = ii.ProviderId
  INNER JOIN dbo.Users u
    ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users ul
    ON ul.UserId = i.LastUpdatedBy
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = i.CreatedInAgencyId
  INNER JOIN dbo.InsurancePolicyStatus s
    ON s.InsurancePolicyStatusId = i.PaymentStatusId
  INNER JOIN dbo.InsurancePolicyStatus sc
    ON sc.InsurancePolicyStatusId = i.CommissionStatusId
  INNER JOIN dbo.Cashiers c
    ON c.UserId = i.CreatedBy
  INNER JOIN dbo.PolicyType pp
    ON pp.PolicyTypeId = ii.PolicyTypeId
  INNER JOIN MonthlyPaymentStatus mps
    ON i.MonthlyPaymentStatusId = mps.MonthlyPaymentStatusId
  INNER JOIN InsuranceCommissionType ict
    ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  LEFT JOIN dbo.Users uv
    ON uv.UserId = i.ValidatedBy
  LEFT JOIN dbo.Agencies av
    ON av.AgencyId = i.ValidatedAgencyId
  LEFT JOIN dbo.InsurancePaymentType ipt
    ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
     INNER JOIN dbo.InsurancePolicy ip
        ON ip.InsurancePolicyId = i.InsurancePolicyId
 LEFT JOIN dbo.InsuranceConceptType icty
    ON icty.Code = 'C03'  -- Se agrega el JOIN aquí
  WHERE (@ClientName IS NULL
  OR ii.ClientName LIKE '%' + @ClientName + '%')
  AND (@ClientTelephone IS NULL
  OR ii.ClientTelephone = @ClientTelephone)
  AND (@PolicyNumber IS NULL
  OR ii.PolicyNumber = @PolicyNumber)
  AND (@InsuranceCompaniesId IS NULL
  OR ii.InsuranceCompaniesId = @InsuranceCompaniesId)
  AND (@PaymentStatusId IS NULL
  OR i.PaymentStatusId = @PaymentStatusId)
  AND (@CommissionStatusId IS NULL
  OR i.CommissionStatusId = @CommissionStatusId)
  AND (i.InsurancePolicyId = @InsurancePolicyId
  OR @InsurancePolicyId IS NULL)
  AND (@ShowMonthlyPayments = CAST(1 AS BIT))
  AND ((@endorsementSelected = CAST(1 AS BIT)
  AND ict.Code = 'C03')
  AND @InsuranceTypeIds IS NOT NULL)
  AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
    AND (@ProviderId IS NULL
  OR ip.ProviderId = @ProviderId)
      AND (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@SelectedAgencyIds))
  OR @SelectedAgencyIds IS NULL)


  UNION ALL

  -- Monthly payments

  SELECT
    NULL AS InsurancePolicyId
   ,i.[InsuranceMonthlyPaymentId]
   ,NULL AS InsuranceRegistrationId
   ,ii.[ProviderId]
   ,ii.[InsuranceCompaniesId]
   ,ii.[ClientName]
   ,ii.[ClientTelephone]
   ,ii.[ExpirationDate]
   ,ii.[PolicyNumber]
   ,i.[USD]
   ,i.[CreatedBy]
   ,i.[CreationDate]
   ,i.[LastUpdatedOn]
   ,i.[LastUpdatedBy]
   ,i.[CreatedInAgencyId]
   ,ii.[PolicyTypeId]
   ,i.[Cash]
   ,i.[PaymentStatusId]
   ,i.[CommissionStatusId]
   ,i.[TelIsCheck]
   ,ii.[ClientTelephone] TelephoneSaved
   ,u.Name AS CreatedByName
   ,ul.Name AS LastUpdatedByName
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,s.Description AS PaymentStatus
   ,s.Description AS CommissionStatus
   ,ict.Description AS Concept
    --	  ,'MONTHLY PAYMENT' as Concept
   ,'C02' AS TypeCode
   ,icty.InsuranceConceptTypeId
   ,p.Name AS Provider
   ,ic.Name AS InsuranceCompany
   ,pp.Description AS PolicyType
    ,CASE
      WHEN i.PaymentType = 'C01' THEN 'CASH'
	   WHEN i.PaymentType = 'C02' THEN 'CARD CUSTOMER'
	   WHEN i.PaymentType = 'C05' THEN 'CARD PAYMENT'
    END AS PaymentType
   ,s.Code AS PaymentStatusCode
   ,s.Description AS PaymentStatusDescription
   ,sc.Code AS CommissionStatusCode
   ,sc.Description AS CommissionStatusDescription
   ,CASE
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C04' THEN [dbo].[fn_CalculateInsuranceAchUsd](NULL, i.InsuranceMonthlyPaymentId, NULL)
      WHEN i.ValidatedUSD IS NOT NULL AND
        ipt.Code = 'C01' THEN i.ValidatedUSD
      ELSE NULL
    END AS ValidatedUSD
   ,i.ValidatedOn
   ,i.ValidatedBy
   ,uv.Name AS ValidatedByName
   ,av.AgencyId AS ValidatedAgencyId
   ,av.Code + ' - ' + av.Name AS ValidatedAgencyCodeName
   ,i.InsurancePaymentTypeId
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN 'CARD CUSTOMER'
      ELSE ipt.Description
    END AS InsurancePaymentTypeDescription
   ,ipt.Code AS InsurancePaymentTypeCode
   ,c.CashierId
   ,CASE
      WHEN i.TransactionId IS NULL OR
        i.TransactionId = '' THEN '-'
      ELSE i.TransactionId
    END AS TransactionId
   ,CASE
      WHEN mps.Description IS NULL OR
        mps.Description = '' THEN '-'
      ELSE mps.Description
    END AS StatusInformation
   ,0 AS MonthlyPaymentUsd
   ,
    --    mps.Description AS StatusInformation,
    [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) AS Adjustment
   ,ii.DOB
   ,(ISNULL(i.USD, 0) + ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CardFee, 0)) AS TotalToPay
   ,ISNULL(i.MonthlyPaymentServiceFee, 0) FeeService
   ,ISNULL(i.CardFee, 0) CardFee
   ,ISNULL(i.CardFee, 0) * -1 CardFeeNegative
   ,ISNULL(i.CommissionUsd, 0) CommissionUsd
   ,(ISNULL(i.MonthlyPaymentServiceFee, 0) * -1) FeeServiceNegative
   ,CASE
      WHEN i.InsurancePaymentTypeId IS NULL AND
        i.PaymentStatusId = @paymentStatusPaidCode THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ValidatedByCashier
    ,NULL
	,NULL
  FROM [dbo].[InsuranceMonthlyPayment] i
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = i.InsurancePolicyId
  INNER JOIN dbo.InsuranceCompanies ic
    ON ic.InsuranceCompaniesId = ii.InsuranceCompaniesId
  INNER JOIN dbo.Providers p
    ON p.ProviderId = ii.ProviderId
  INNER JOIN dbo.Users u
    ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users ul
    ON ul.UserId = i.LastUpdatedBy
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = i.CreatedInAgencyId
  INNER JOIN dbo.InsurancePolicyStatus s
    ON s.InsurancePolicyStatusId = i.PaymentStatusId
  INNER JOIN dbo.InsurancePolicyStatus sc
    ON sc.InsurancePolicyStatusId = i.CommissionStatusId
  INNER JOIN dbo.Cashiers c
    ON c.UserId = i.CreatedBy
  INNER JOIN dbo.PolicyType pp
    ON pp.PolicyTypeId = ii.PolicyTypeId
  INNER JOIN MonthlyPaymentStatus mps
    ON i.MonthlyPaymentStatusId = mps.MonthlyPaymentStatusId
  INNER JOIN InsuranceCommissionType ict
    ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  LEFT JOIN dbo.Users uv
    ON uv.UserId = i.ValidatedBy
  LEFT JOIN dbo.Agencies av
    ON av.AgencyId = i.ValidatedAgencyId
  LEFT JOIN dbo.InsurancePaymentType ipt
    ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
     INNER JOIN dbo.InsurancePolicy ip
        ON ip.InsurancePolicyId = i.InsurancePolicyId
  LEFT JOIN dbo.InsuranceConceptType icty
    ON icty.Code = 'C02'  -- Se agrega el JOIN aquí
  WHERE (@ClientName IS NULL
  OR ii.ClientName LIKE '%' + @ClientName + '%')
  AND (@ClientTelephone IS NULL
  OR ii.ClientTelephone = @ClientTelephone)
  AND (@PolicyNumber IS NULL
  OR ii.PolicyNumber = @PolicyNumber)
  AND (@InsuranceCompaniesId IS NULL
  OR ii.InsuranceCompaniesId = @InsuranceCompaniesId)
  AND (@PaymentStatusId IS NULL
  OR i.PaymentStatusId = @PaymentStatusId)
  AND (@CommissionStatusId IS NULL
  OR i.CommissionStatusId = @CommissionStatusId)
  AND (i.InsurancePolicyId = @InsurancePolicyId
  OR @InsurancePolicyId IS NULL)
  AND (@ShowMonthlyPayments = CAST(1 AS BIT))
  AND ((@policyRenewalSelected = CAST(1 AS BIT)
  AND ict.Code = 'C02')
  AND @InsuranceTypeIds IS NOT NULL)
  AND (CAST(i.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(i.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
      AND (@ProviderId IS NULL
  OR ip.ProviderId = @ProviderId)
      AND (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@SelectedAgencyIds))
  OR @SelectedAgencyIds IS NULL)


  ORDER BY CreationDate ASC;

END
GO