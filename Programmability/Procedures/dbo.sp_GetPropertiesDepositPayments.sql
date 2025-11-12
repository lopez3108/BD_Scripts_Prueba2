SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT

CREATE PROCEDURE [dbo].[sp_GetPropertiesDepositPayments] (@PropertiesIds VARCHAR(100),
@FromDate DATETIME,
@ToDate DATETIME)
AS
BEGIN
  SELECT
    d.DepositFinancingPaymentsId
   ,c.ContractId
   ,d.Usd
   ,CASE
      WHEN d.AchDate IS NOT NULL THEN d.AchDate
      ELSE d.CreationDate
    END AS CreationDate
   ,c.ApartmentId
   ,t.Name AS TenantName
   ,a.Number
   ,p.Name AS PropertyName
  FROM DepositFinancingPayments d
  INNER JOIN Contract c
    ON c.ContractId = d.ContractId
  INNER JOIN Apartments a
    ON a.ApartmentsId = c.ApartmentId
  INNER JOIN Properties p
    ON a.PropertiesId = p.PropertiesId
  INNER JOIN dbo.TenantsXcontracts AS tc
    ON c.ContractId = tc.ContractId
      AND tc.Principal = 1
  INNER JOIN dbo.Tenants AS t
    ON tc.TenantId = t.TenantId
  WHERE (
  (
  d.AchDate IS NOT NULL
  AND CAST(d.AchDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
  )
  OR (
  d.AchDate IS NULL
  AND CAST(d.CreationDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
  )
  )


  AND p.PropertiesId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@PropertiesIds))
END;


GO