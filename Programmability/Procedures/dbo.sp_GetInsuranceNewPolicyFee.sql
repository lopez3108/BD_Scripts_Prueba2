SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-27 DJ/6266: Aplicar comisión provider a los insurance - NEW POLICY

CREATE PROCEDURE [dbo].[sp_GetInsuranceNewPolicyFee]
@ProviderId INT
AS 

BEGIN

SELECT 
c.InsuranceCommissionTypeId,
c.Code,
ISNULL(i.FeeService, 0) as FeeService,
ISNULL(i.USD,0) as CommissionUsd
 FROM dbo.InsuranceCommissionType c  LEFT JOIN
dbo.InsuranceCommissionTypeXProvider i ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
AND i.ProviderId = @ProviderId
WHERE c.Code = 'C01'


  

	END
GO