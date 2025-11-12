SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesDepositRefunds]
(@PropertiesIds         VARCHAR(100),
 @FromDate        DATETIME,
  @ToDate        DATETIME
)
AS
     BEGIN


SELECT 
c.ContractId,
c.ContractId,
((SELECT SUM(Usd) FROM DepositFinancingPayments d WHERE d.ContractId = c.ContractId)) as Usd,
c.RefundDate as CreationDate,
c.ApartmentId,
t.Name as TenantName, 
a.Number, 
p.Name AS PropertyName
FROM 
Contract c INNER JOIN
Apartments a on a.ApartmentsId = c.ApartmentId INNER JOIN
Properties p on a.PropertiesId = p.PropertiesId INNER JOIN
						 dbo.TenantsXcontracts AS tc ON c.ContractId = tc.ContractId AND tc.Principal = 1 INNER JOIN
						 dbo.Tenants AS t ON tc.TenantId = t.TenantId
WHERE 
c.RefundDate IS NOT NULL AND
CAST(c.RefundDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(c.RefundDate as DATE) <= CAST(@ToDate as DATE) AND
 p.PropertiesId IN	
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)

			 )

        


     END;
GO