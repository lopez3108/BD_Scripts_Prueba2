SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-09-05 JF/6722: Contracts deben poder quedar en status PENDING cuando se crean
-- 2025-10-03 JF/6779: Ng error incorrecto al momento de cerrar un contrato

CREATE PROCEDURE [dbo].[sp_GetContractInformationPendingById] @ContractId INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    -- Estado general del contrato (bandera Contract.IsPendingInformation)
    CASE
      WHEN EXISTS (SELECT
            1
          FROM Contract c
          WHERE c.ContractId = @ContractId
          AND c.IsPendingInformation = 1) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS IsPendingInformation
   ,

    -- Validación de archivos asociados al contrato
    CASE
      WHEN EXISTS (SELECT
            1
          FROM Contract c
          WHERE c.ContractId = @ContractId
          AND (c.ContractFileName IS NULL
          OR LTRIM(RTRIM(c.ContractFileName)) = '')) THEN CAST(1 AS BIT)   -- Falta archivo (pendiente)
      ELSE CAST(0 AS BIT)   -- Sí tiene archivo
    END AS IsPendingFileName
   ,


    -- EstadoTenant único (si al menos un tenant está incompleto)
    CASE
      WHEN EXISTS (SELECT
            1
          FROM TenantsXcontracts tx
          INNER JOIN Tenants t
            ON tx.TenantId = t.TenantId
          LEFT JOIN ContractFiles cf
            ON cf.ContractId = tx.ContractId
            AND cf.TenantId = t.TenantId
          WHERE tx.ContractId = @ContractId
          AND (t.Telephone IS NULL
          OR t.TypeId IS NULL
          OR t.DocNumber IS NULL
          OR cf.ContractFileId IS NULL)) THEN CAST(1 AS BIT)   -- Algún tenant incompleto
      ELSE CAST(0 AS BIT)   -- Todos completos
    END AS IsPendingTenant;
END;
GO