SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT
--Created by jf/26-09-2025 task 6763 Bugs generales del proceso Fee due, ACH date y view contract

CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsRentPayments]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN

SELECT
  dbo.RentPayments.RentPaymentId
 ,dbo.RentPayments.ContractId
 ,dbo.RentPayments.UsdPayment AS Usd
  ,CASE WHEN RentPayments.AchDate IS NOT NULL THEN RentPayments.AchDate ELSE  RentPayments.CreationDate end AS CreationDate

 ,dbo.Contract.ApartmentId
 ,
  --TC.TenantsXcontractId,TC.ContractId , ISNULL(TC.Principal , 0) Principal, T.Name as TenantName,
  T.Name AS TenantName
 ,dbo.Apartments.Number
 ,dbo.Properties.Name AS PropertyName
 FROM dbo.RentPayments
INNER JOIN dbo.Contract
  ON dbo.RentPayments.ContractId = dbo.Contract.ContractId
INNER JOIN dbo.Apartments
  ON dbo.Contract.ApartmentId = dbo.Apartments.ApartmentsId
INNER JOIN dbo.Properties
  ON dbo.Apartments.PropertiesId = dbo.Properties.PropertiesId
INNER JOIN dbo.TenantsXcontracts AS TC
  ON dbo.Contract.ContractId = TC.ContractId
    AND TC.Principal = 1
INNER JOIN dbo.Tenants AS T
  ON TC.TenantId = T.TenantId
--dbo.Tenants ON dbo.Contract.TenantId = dbo.Tenants.TenantId
WHERE dbo.RentPayments.UsdPayment > 0
AND (( RentPayments.AchDate IS NOT NULL
        AND CAST(RentPayments.AchDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(RentPayments.AchDate AS DATE) <= CAST(@ToDate AS DATE))
        OR  ( RentPayments.AchDate IS NULL
        AND CAST(RentPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(RentPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))

AND dbo.Properties.PropertiesId IN (SELECT
    item
  FROM dbo.FN_ListToTableInt(@PropertiesIds))
END;


GO