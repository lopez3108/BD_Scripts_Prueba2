SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesXApartmenList] 
													 AS
    BEGIN
        SELECT DISTINCT
		Apartments.ApartmentsId,
		Properties.CreationDate,
		Properties.CreatedBy,
		Properties.propertiesId,
		 CASE
                   WHEN con.ContractId IS NOT NULL
                   THEN CAST(1 AS BIT)
                   ELSE CAST(0 AS BIT)
               END AS HasContract
  FROM dbo.Properties
        INNER JOIN dbo.Apartments ON dbo.Properties.PropertiesId = dbo.Apartments.PropertiesId
		INNER JOIN dbo.Contract con ON dbo.Apartments.ApartmentsId = con.ApartmentId
		      --   LEFT OUTER JOIN
        --(
        --    SELECT dbo.[Contract].ContractId, 
        --           dbo.[Contract].ApartmentId, 
        --           dbo.[Tenants].Name, 
        --           dbo.[Contract].TenantId
        --    FROM dbo.[Contract]
        --         INNER JOIN Tenants ON Tenants.TenantId = dbo.[Contract].TenantId
        --    WHERE Status = 1
        --) AS con ON con.ApartmentId = dbo.Apartments.ApartmentsId
            
       
    END;


GO