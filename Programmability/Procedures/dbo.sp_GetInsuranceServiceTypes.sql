SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-30 DJ/6261: Aplicar comisión provider a los insurance - MONTHLY PAYMENTS
--2025-01-10- LP/6275: se organiza el orden service type en el insurance- MONTHLY PAYMENTS
CREATE PROCEDURE [dbo].[sp_GetInsuranceServiceTypes] 
AS

BEGIN

  SELECT
    i.InsuranceCommissionTypeId
   ,i.Code
   ,i.Description
  FROM dbo.InsuranceCommissionType AS i
  WHERE i.Code <> 'C01'
  ORDER BY i.CodeOrder ASC

END
GO