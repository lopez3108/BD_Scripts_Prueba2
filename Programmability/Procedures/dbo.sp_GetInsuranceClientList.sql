SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-10 CB/6019: Gets insurance list of clients

CREATE PROCEDURE [dbo].[sp_GetInsuranceClientList]
@Name VARCHAR(50)
AS 

BEGIN

SELECT DISTINCT 
      i.[ClientName]
  FROM [dbo].[InsurancePolicy] i
  WHERE i.[ClientName] LIKE '%' + @Name + '%'

  UNION ALL

  SELECT DISTINCT
      i.[ClientName]
  FROM [dbo].[InsuranceRegistration] i
  WHERE i.[ClientName] LIKE '%' + @Name + '%'

	END
GO