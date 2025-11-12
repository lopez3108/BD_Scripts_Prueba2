SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-09-15 JF/6732: Ajuste eviction notice properties

CREATE PROCEDURE [dbo].[sp_CreateDocumentXContract]
  @DocumentXContractID INT = NULL,
  @ContractId   INT = NULL,
  @FileName     VARCHAR(256) = NULL,
  @UploadDate   DATETIME,
  @LastUpdatedBy INT = NULL,
  @IdCreated      INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  IF (@DocumentXContractID <= 0 )
  BEGIN
    INSERT INTO dbo.DocumentsXContract
        (ContractId, FileName, UploadDate, LastUpdatedBy)
    VALUES
        (@ContractId, @FileName, @UploadDate, @LastUpdatedBy);

    SET @IdCreated = @@IDENTITY;
  END
  ELSE
  BEGIN
    UPDATE dbo.DocumentsXContract
    SET FileName = @FileName,
        UploadDate = @UploadDate,
        LastUpdatedBy = @LastUpdatedBy
    WHERE DocumentXContractID = @DocumentXContractID;

    SET @IdCreated = @DocumentXContractID;
  END
END
GO