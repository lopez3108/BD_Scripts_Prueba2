SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 27/09/2024 12:36 p. m.
-- Database:    developing
-- Description: task 6072 Permitir adjuntar documentos a los diferentes movimientos
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateDocumentXInsurance] @DocumentXInsuranceID INT = NULL,
@InsuranceId    INT = NULL,
@FileName       varchar(256) = NULL,
@FileType       varchar(256) = NULL,
@UploadDate     DATETIME,
@LastUpdatedBy  INT = NULL


AS
BEGIN
  IF (@DocumentXInsuranceID IS NULL)
  BEGIN
    INSERT INTO [dbo].[DocumentsXInsurance] ([InsuranceID], [FileName], [FileType], [UploadDate],[LastUpdatedBy])
      VALUES (@InsuranceId, @FileName, @FileType, @UploadDate, @LastUpdatedBy);
    SELECT  @@IDENTITY;
    
  END
  ELSE
BEGIN
     UPDATE [dbo].DocumentsXInsurance
                   SET
                    FileName = @FileName,
                    FileType = @FileType,
                    UploadDate = @UploadDate,
                    LastUpdatedBy =  @LastUpdatedBy		
				                   
                 WHERE DocumentXInsuranceID = @DocumentXInsuranceID;
				   SELECT @DocumentXInsuranceID;


END



END;

GO