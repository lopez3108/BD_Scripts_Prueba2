SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-09-23 jf/6750 Ligar ids a tennants


CREATE PROCEDURE [dbo].[sp_GetTenantsXProperties] @contractId INT = NULL
AS
    BEGIN

  SELECT 
  TXC.TenantsXcontractId,TXC.ContractId ,
  ISNULL(txc.Principal , 0) Principal,
  TID.Description DescriptionDocType, 
  cf.ContractFileId, 
  cf.FileName,
  T.*
  FROM TenantsXcontracts AS TXC 
  INNER JOIN [dbo].Tenants as T ON (TXC.TenantId = T.TenantId )
  LEFT JOIN ContractFiles cf ON T.TenantId = cf.TenantId
  LEFT JOIN [dbo].TypeID AS TID ON T.TypeId = TID.TypeId
 WHERE TXC.ContractId = @contractId

ORDER BY txc.Principal DESC

END;


GO