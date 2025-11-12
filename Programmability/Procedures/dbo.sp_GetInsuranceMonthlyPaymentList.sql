SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JT
-- Create date: 10/10/2024 12:21 p. m.
-- Database:    developing
-- Description: task 6075 Get list of monthly payments by policy
-- =============================================



CREATE PROCEDURE [dbo].[sp_GetInsuranceMonthlyPaymentList] @InsurancePolicyId INT = NULL

AS

BEGIN
  SELECT
    RowNum = ROW_NUMBER() OVER (ORDER BY CreationDate)
   ,*
  FROM (SELECT
  CAST(1 AS BIT) IsNewPolicy,
      i.[InsurancePolicyId]
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
     ,p.Name AS Provider
     ,ic.Name AS InsuranceCompany
     ,pp.Description AS PolicyType
     ,CASE
        WHEN i.USD = 0 THEN 'CARD CUSTOMER'
        ELSE 'CASH'
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
     ,ipt.Description AS InsurancePaymentTypeDescription
     ,ipt.Code AS InsurancePaymentTypeCode
     ,c.CashierId
     ,[dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) AS Adjustment
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
    WHERE i.InsurancePolicyId = @InsurancePolicyId
    AND CAST(i.CreatedByMonthlyPayment AS BIT) = 0 OR  i.CreatedByMonthlyPayment = NULL
    UNION ALL

    SELECT
  CAST(0 AS BIT)  IsNewPolicy,
      i.[InsuranceMonthlyPaymentId]
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
     ,'MONTHLY PAYMENT' AS Concept
     ,'C02' AS TypeCode
     ,p.Name AS Provider
     ,ic.Name AS InsuranceCompany
     ,pp.Description AS PolicyType
     ,CASE
        WHEN i.USD = 0 THEN 'CARD CUSTOMER'
        ELSE 'CASH'
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
     ,ipt.Description AS InsurancePaymentTypeDescription
     ,ipt.Code AS InsurancePaymentTypeCode
     ,c.CashierId
     ,[dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) AS Adjustment
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
    LEFT JOIN dbo.Users uv
      ON uv.UserId = i.ValidatedBy
    LEFT JOIN dbo.Agencies av
      ON av.AgencyId = i.ValidatedAgencyId
    LEFT JOIN dbo.InsurancePaymentType ipt
      ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
    WHERE
    --  (@ClientName IS NULL
    --  OR ii.ClientName = @ClientName)
    --  AND (@ClientTelephone IS NULL
    --  OR ii.ClientTelephone = @ClientTelephone)
    --  AND (@PolicyNumber IS NULL
    --  OR ii.PolicyNumber = @PolicyNumber)
    --  AND (@InsuranceCompaniesId IS NULL
    --  OR ii.InsuranceCompaniesId = @InsuranceCompaniesId)
    --  AND (@PaymentStatusId IS NULL
    --  OR i.PaymentStatusId = @PaymentStatusId)
    --  AND (@CommissionStatusId IS NULL
    --  OR i.CommissionStatusId = @CommissionStatusId)
    --AND
    (i.InsurancePolicyId = @InsurancePolicyId
    OR @InsurancePolicyId IS NULL)) AS Q
END




GO