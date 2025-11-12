SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetValidarCompanyExist]
@CompanyName VARCHAR(50)
AS

     BEGIN
        SELECT * 
		FROM dbo.Companies
		WHERE CompanyName LIKE @CompanyName
     END;
GO