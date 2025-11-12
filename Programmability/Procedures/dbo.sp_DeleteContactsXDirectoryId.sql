SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteContactsXDirectoryId] @ContactsXDirectoryId int
AS
BEGIN
    DELETE ContactsXDirectory
    WHERE ContactsXDirectoryId = @ContactsXDirectoryId
END
GO