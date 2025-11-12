SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-23 DJ/6250: Nueva comisión para config de los providers tipo INSURANCE
-- 2025-01-10 LP/6275: Ordenamiento de los servicios debe ser: New policy , policy renewal , monthly payment, endorsentmet

CREATE PROCEDURE [dbo].[sp_GetInsuranceProviderCommissionTypes] @ProviderId INT = NULL
AS

BEGIN

  SELECT 
    i.InsuranceCommissionTypeId
   ,c.InsuranceCommissionTypeXProvider
   ,@ProviderId AS ProviderId
   ,i.Code
   ,i.Description
   ,ISNULL(c.USD, 0) AS Usd
   ,ISNULL(c.FeeService, 0) AS FeeService
  FROM dbo.InsuranceCommissionType AS i
  LEFT OUTER JOIN dbo.InsuranceCommissionTypeXProvider AS c
    ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
      AND c.ProviderId = @ProviderId
	  order by i.CodeOrder asc

END
GO