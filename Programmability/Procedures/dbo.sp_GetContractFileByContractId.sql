SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-10-08 jf/6784: Ajuste para evitar error al eliminar contrato (validación por ContractId)

CREATE PROCEDURE [dbo].[sp_GetContractFileByContractId]
    @ContractId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cf.ContractFileId,
        cf.FileType
    FROM 
        ContractFiles AS cf
    WHERE 
        cf.ContractId = @ContractId;
END;
GO