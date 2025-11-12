SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDocumentHead] @DocumentId INT = NULL
AS
    BEGIN
        SELECT *
        FROM documentinformation di
        WHERE di.DocumentId = @DocumentId
              OR @DocumentId IS NULL;
    END;
GO