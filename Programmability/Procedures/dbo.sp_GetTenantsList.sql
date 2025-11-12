SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetTenantsList]  @OnlyActiveContracts  BIT = NULL

AS
    BEGIN
        SELECT dbo.Tenants.Name + ' - ' + a.Number + ' - ' + p.Name AS tenantName, 
               Tenants.Telephone, 
               P.PropertiesId, 
               P.Name PropertyName, 
               P.PersonInChargeTelephone AS CompanyPhone, 
               a.Number
        FROM dbo.Tenants
             INNER JOIN dbo.TenantsXcontracts tc ON TC.TenantId = dbo.Tenants.TenantId
             INNER JOIN Contract c ON c.Contractid = tc.ContractId
             --INNER JOIN dbo.Tenants ON Tenants.TenantId = TC.TenantId
             INNER JOIN dbo.TypeID ON dbo.Tenants.TypeId = dbo.TypeID.TypeId
             INNER JOIN Apartments a ON a.ApartmentsId = c.ApartmentId
             INNER JOIN Properties p ON p.PropertiesId = a.PropertiesId
             WHERE c.Status = @OnlyActiveContracts OR @OnlyActiveContracts IS NULL

    END;
GO