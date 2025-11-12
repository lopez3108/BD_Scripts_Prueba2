SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-23 CB/6015: Gets the insurance companies list
--2025-01-09 LP/6274 remover monthly payments (Fee service)
-- 2025-02-07 DJ/6335: Agregar Campo URL en la Configuración de Insurance Companies

CREATE PROCEDURE [dbo].[sp_GetInsuranceCompanies]

AS 

BEGIN

SELECT [InsuranceCompaniesId]
      ,i.[Name]
      ,[CreatedBy]
      ,[CreationDate]
      ,[LastUpdatedBy]
      ,[LastUpdatedOn]
	  ,u.Name as CreatedByName
	  ,uu.Name as LastUpdatedByName
	  ,i.[URL]
  FROM [dbo].[InsuranceCompanies] i
  INNER JOIN dbo.Users u ON u.UserId = i.CreatedBy
  INNER JOIN dbo.Users uu ON uu.UserId = i.LastUpdatedBy


	END
GO