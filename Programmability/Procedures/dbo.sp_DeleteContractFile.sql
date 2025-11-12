SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-19 jf/6750 Ligar ids a tenants
-- 2025-10-08 jf/6784: Ajuste para evitar error al eliminar contrato (validación por ContractId)

CREATE PROCEDURE [dbo].[sp_DeleteContractFile] 
  @ContractFileId INT = NULL, 
  @ContractId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  IF @ContractFileId IS NOT NULL
  BEGIN
    DELETE FROM ContractFiles
    WHERE ContractFileId = @ContractFileId;
  END
  ELSE IF @ContractId IS NOT NULL
  BEGIN
    DELETE FROM ContractFiles
    WHERE ContractId = @ContractId;
  END
  ELSE
  BEGIN
    SELECT -1 AS Result;  -- Ningún parámetro válido
    RETURN;
  END
END;
GO