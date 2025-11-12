SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCompanies] @CompanyName                 VARCHAR(50) = NULL, 
                                        @CompanyType                 INT         = NULL, 
                                        @TypeOfInternationalTopUpsId INT         = NULL
AS
    BEGIN
        SELECT c.CompanyId, 
               c.CompanyName, 
               c.CompanyType, 
               t.Code, 
               t.CompanyTypeName 
              
        FROM dbo.Companies c
             INNER JOIN dbo.CompanyType t ON c.CompanyType = t.CompanyType
        WHERE (c.CompanyName = @CompanyName
              OR @CompanyName IS NULL)
              AND (c.CompanyType = @CompanyType
              OR @CompanyType IS NULL)
            
    END;
GO