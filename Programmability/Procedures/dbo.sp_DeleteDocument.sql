SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteDocument](@DocumentId INT)
AS
    BEGIN
        --SELECT DocumentByClientId
        --FROM Documents
        --WHERE DocumentId = @DocumentId;

        DELETE documentinformation
        WHERE DocumentId = @DocumentId;
        DELETE Documents
        WHERE DocumentId = @DocumentId;
        SELECT 1;
    END;
GO