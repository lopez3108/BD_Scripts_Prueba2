SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-18 JF/6351: Ajuste Configuración de Comisiones para Providers tipo INSURANCE - NEW POLICY

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceCommissionPolicyTypeMovement] @InsuranceCommissionTypeId INT, @ProviderId INT
AS

BEGIN


  DELETE FROM [dbo].[InsuranceCommissionPolicyTypeMovement]
  WHERE InsuranceCommissionTypeId = @InsuranceCommissionTypeId
    AND ProviderId = @ProviderId

  SELECT
    @InsuranceCommissionTypeId

END

GO