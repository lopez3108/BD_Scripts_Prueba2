SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-19 jf/6750 Ligar ids a tennants

CREATE PROCEDURE [dbo].[sp_GetContractFiles] (@ContractId INT = NULL, @FileType  VARCHAR(50))

AS
BEGIN

  -- Archivos tipo Document
  SELECT
    cf.ContractFileId
   ,cf.FileName
   ,cf.FileType
   ,t.Name AS TenantName
  FROM ContractFiles cf
  LEFT JOIN Tenants t ON cf.TenantId = t.TenantId
  WHERE cf.ContractId = @ContractId AND cf.FileType = @FileType



END


GO