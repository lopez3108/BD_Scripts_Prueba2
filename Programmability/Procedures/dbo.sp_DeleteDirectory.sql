SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteDirectory](@DirectoryId INT)
AS
    -- 1) delete  all contactsXDirectory where @DirectoryId
BEGIN
    DELETE ContactsXDirectory
    WHERE DirectoryId = @DirectoryId;

    -- 2) delete directory
    DELETE Directory
    WHERE DirectoryId = @DirectoryId;
END;
GO