SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 3/10/2024 5:04 p. m.
-- Database:    developing
-- Description: 6072  task Permitir adjuntar documentos a los diferentes movimientos
-- =============================================

CREATE PROCEDURE [dbo].[sp_DeleteDocumentXInsurance] @DocumentXInsuranceID INT = NULL,@InsuranceId INT = NULL
AS

BEGIN

IF @DocumentXInsuranceID IS NOT NULL BEGIN DELETE dbo.DocumentsXInsurance
  WHERE DocumentXInsuranceID = @DocumentXInsuranceID 
	
END ELSE
IF @InsuranceId IS NOT NULL BEGIN 
  DELETE dbo.DocumentsXInsurance
  WHERE InsuranceID = @InsuranceId 
	
END

END



GO