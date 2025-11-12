SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-10 CB/6019: Gets policy payment type

CREATE PROCEDURE [dbo].[sp_GetInsurancePolicyStatus]

AS 

BEGIN

SELECT [InsurancePolicyStatusId]
      ,[Code]
      ,[Description]
  FROM [dbo].[InsurancePolicyStatus]



	END
GO