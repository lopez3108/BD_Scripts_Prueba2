SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllTenantsByProperties] @PropertiesId VARCHAR(500) = NULL, @OnlyActiveContracts BIT = NULL,@Date DATETIME = NULL

AS
BEGIN

  SELECT   
  Tenants.Telephone
    ,dbo.Tenants.Name + ' - ' + a.number + ' - ' + p.Name  AS tenantName  
   ,p.PropertiesId
   ,p.Name PropertyName
   ,p.PersonInChargeTelephone AS CompanyPhone
   ,a.number
   , Ti.Description
   ,Tenants.DocNumber 
  FROM dbo.Tenants
  INNER JOIN dbo.TenantsXcontracts tc
    ON tc.TenantId = dbo.Tenants.TenantId
  INNER JOIN Contract c
    ON c.ContractId = tc.ContractId
    INNER JOIN  ContractStatus CS ON CS.ContractStatusId = C.Status
  --INNER JOIN dbo.Tenants ON Tenants.TenantId = TC.TenantId
  INNER JOIN dbo.TypeId
    ON dbo.Tenants.TypeId = dbo.TypeId.TypeId
  INNER JOIN Apartments a
    ON a.ApartmentsId = c.ApartmentId
  INNER JOIN Properties p
    ON p.PropertiesId = a.PropertiesId

INNER JOIN TypeID ti ON Tenants.TypeId = ti.TypeId

  WHERE (a.PropertiesId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@PropertiesId))
  OR (@PropertiesId = ''
  OR @PropertiesId IS NULL))
  AND (@OnlyActiveContracts = 1 AND CS.Code = 'C01' OR (@OnlyActiveContracts IS NULL OR @OnlyActiveContracts = 0))
  AND (C.StartDate <= @Date ) 



END;




GO