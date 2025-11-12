SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 27/09/2024 5:18 p. m.
-- Database:    developing
-- Description: task 6072 Permitir adjuntar documentos a los diferentes movimientos
-- =============================================

-- 2024-11-19 DJ/6204: Permitir descargar los documentos de los insurance


CREATE PROCEDURE [dbo].[sp_GetDocumentXInsurance] @InsurancePolicyId   INT = NULL, @FileType VARCHAR(50)


AS
BEGIN
 SELECT 
 dx.DocumentXInsuranceID,
 dx.FileName, 
 u.Name AS lastUpdatedName,
 dx.UploadDate AS UploadDate,
 dx.FileType
 FROM DocumentsXInsurance dx
 LEFT JOIN Users u ON dx.LastUpdatedBy = u.UserId
 WHERE @InsurancePolicyId = dx.InsuranceID AND @FileType = dx.FileType 
 ORDER BY dx.UploadDate DESC
    
  END



GO