SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTenants] @TenantId INT = NULL
AS
     BEGIN
         SELECT dbo.Tenants.TenantId,
                dbo.Tenants.Name,
				dbo.Tenants.Name + ' - ID #' + dbo.Tenants.DocNumber as NameId,
                dbo.Tenants.Telephone,
                dbo.Tenants.TypeId,
                dbo.TypeID.Description,
                dbo.Tenants.DocNumber
         FROM dbo.Tenants
              INNER JOIN dbo.TypeID ON dbo.Tenants.TypeId = dbo.TypeID.TypeId
         WHERE(@TenantId IS NULL
               OR @TenantId = dbo.Tenants.TenantId);
     END;
GO