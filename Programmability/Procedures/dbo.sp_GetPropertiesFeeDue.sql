SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/26-09-2025 task 6763 Bugs generales del proceso Fee due, ACH date y view contract

CREATE PROCEDURE [dbo].[sp_GetPropertiesFeeDue]
(@PropertiesIds         VARCHAR(100),
 @FromDate        DATETIME,
  @ToDate        DATETIME
)
AS
     BEGIN
        
SELECT        
r.RentPaymentId, 
r.ContractId, 
r.FeeDue as Usd, 
r.CreationDate, 
dbo.Contract.ApartmentId, 
--TC.TenantsXcontractId,TC.ContractId , ISNULL(TC.Principal , 0) Principal, T.Name as TenantName,
T.Name as TenantName, 
dbo.Apartments.Number, 
dbo.Properties.Name AS PropertyName
FROM            dbo.RentPayments r INNER JOIN
                         dbo.Contract ON r.ContractId = dbo.Contract.ContractId INNER JOIN
                         dbo.Apartments ON dbo.Contract.ApartmentId = dbo.Apartments.ApartmentsId INNER JOIN
                         dbo.Properties ON dbo.Apartments.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
						 dbo.TenantsXcontracts AS TC ON dbo.Contract.ContractId = TC.ContractId AND TC.Principal = 1 INNER JOIN
						 dbo.Tenants AS T ON TC.TenantId = T.TenantId
                         --dbo.Tenants ON dbo.Contract.TenantId = dbo.Tenants.TenantId
						 WHERE
						 r.FeeDue > 0 AND
  (( r.AchDate IS NOT NULL
  AND CAST(r.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(r.AchDate AS DATE) <= CAST(@ToDate AS DATE))
  OR (  r.AchDate IS NULL
  AND CAST(r.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(r.CreationDate AS DATE) <= CAST(@ToDate AS DATE))) AND
 dbo.Properties.PropertiesId IN	
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )









     END;

GO