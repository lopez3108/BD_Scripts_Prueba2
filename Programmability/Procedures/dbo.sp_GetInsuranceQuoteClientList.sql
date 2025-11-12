SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteClientList]
@Name VARCHAR(50)
AS 

BEGIN

SELECT DISTINCT 
      i.[ClientName]
  FROM [dbo].[InsuranceQuote] i
  WHERE i.[ClientName] LIKE '%' + @Name + '%'



	END
GO