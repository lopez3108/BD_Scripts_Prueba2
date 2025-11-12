SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-17 JF/6351: Ajuste Configuración de Comisiones para Providers tipo INSURANCE - NEW POLICY

CREATE PROCEDURE [dbo].[sp_GetInsuranceCommissionPolicyTypeMovement] (@InsuranceCommissionTypeId INT = NULL,
    @ProviderId INT = NULL)
AS

BEGIN

SELECT 
    icptm.InsuranceCommissionPolicyTypeMovementId,
    pt.PolicyTypeId,
    ict.Description AS CommissionType,
    pt.Description,
    ISNULL(icptm.USD, 0) AS Usd
FROM dbo.PolicyType pt
LEFT OUTER JOIN dbo.InsuranceCommissionPolicyTypeMovement icptm 
    ON pt.PolicyTypeId = icptm.PolicyTypeId 
    AND icptm.InsuranceCommissionTypeId = @InsuranceCommissionTypeId 
    AND icptm.ProviderId = @ProviderId  -- Este filtro se aplica solo dentro del JOIN
LEFT OUTER JOIN InsuranceCommissionType ict 
    ON icptm.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
LEFT OUTER JOIN Providers p 
    ON icptm.ProviderId = p.ProviderId
--ORDER BY pt.Description ASC


END



GO