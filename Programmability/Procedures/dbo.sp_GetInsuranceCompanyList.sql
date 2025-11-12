SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-10 CB/6019: Gets insurance list of companies

CREATE PROCEDURE [dbo].[sp_GetInsuranceCompanyList]
@Name VARCHAR(50)
AS 

BEGIN

SELECT DISTINCT 
i.InsuranceCompaniesId,
      i.[Name]
  FROM [dbo].[InsuranceCompanies] i
  WHERE i.[Name] LIKE '%' + @Name + '%'

  

	END
GO