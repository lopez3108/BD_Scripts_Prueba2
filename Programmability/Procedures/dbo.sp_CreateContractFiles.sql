SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateContractFiles] @ContractFileId INT = NULL,
@ContractId INT = NULL,
@TenantId INT = NULL,
@FileName NVARCHAR(200) = NULL,
@FileType NVARCHAR(50) = NULL,      -- 'DOCUMENT' o 'OTHER'
@UploadDate DATETIME,
@LastUpdatedBy INT = NULL,
@IdCreated INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  -- Si no hay FileId, insertamos
  IF (@ContractFileId IS NULL
    OR @ContractFileId <= 0)
  BEGIN
    INSERT INTO dbo.ContractFiles (ContractId, TenantId, FileName, FileType, UploadDate, LastUpdatedBy)
      VALUES (@ContractId, @TenantId, @FileName, @FileType, @UploadDate, @LastUpdatedBy);

    SET @IdCreated = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE dbo.ContractFiles
    SET FileName = @FileName
       ,FileType = @FileType
       ,UploadDate = @UploadDate
       ,LastUpdatedBy = @LastUpdatedBy
    WHERE ContractFileId = @ContractFileId;

    SET @IdCreated = @ContractFileId;
  END
END
GO