SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTenantsByContract](@ContractId INT)
AS
    BEGIN
        SELECT t.Name,
               t.Telephone,
			   ti.Description as DocType,
              t.DocNumber,
			  tc.Principal,
			  CASE
			  WHEN tc.Principal = CAST(1 as BIT) THEN 'YES' ELSE 'NO'
			  END as IsPrincipal,
			  '' as DeleteTenant
        FROM dbo.Tenants t 
			INNER JOIN TypeID ti ON ti.TypeId = t.TypeId
             INNER JOIN dbo.TenantsXcontracts tc ON TC.TenantId = t.TenantId
             INNER JOIN Contract c ON c.Contractid = tc.ContractId
             INNER JOIN Apartments a ON a.ApartmentsId = c.ApartmentId
             INNER JOIN Properties p ON p.PropertiesId = a.PropertiesId
			 WHERE tc.ContractId = @ContractId
			 ORDER BY tc.Principal DESC
    END;
GO