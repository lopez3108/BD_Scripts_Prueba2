SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-30 DJ/6261: Aplicar comisión provider a los insurance - MONTHLY PAYMENTS

CREATE PROCEDURE [dbo].[sp_GetInsuranceServiceTypeFee]
@ProviderId INT,
@InsuranceCommissionTypeId INT
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
WHERE c.InsuranceCommissionTypeId = @InsuranceCommissionTypeId


  

	END
GO