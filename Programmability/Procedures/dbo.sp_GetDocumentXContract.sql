SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-09-16 DJ/6732: Ajuste eviction notice properties

CREATE PROCEDURE [dbo].[sp_GetDocumentXContract] @ContractId INT = NULL


AS
BEGIN
  SELECT
    dx.DocumentXContractID
   ,dx.FileName
   ,u.Name AS lastUpdatedName
   ,dx.UploadDate AS UploadDate

  FROM DocumentsXContract dx
  LEFT JOIN Users u
    ON dx.LastUpdatedBy = u.UserId
  WHERE @ContractId = dx.ContractId
  ORDER BY dx.UploadDate DESC

END




GO