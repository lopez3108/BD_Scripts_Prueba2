SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetContactsXDirectory] @DirectoryId int = null
AS
BEGIN
    select ContactsXDirectoryId, DirectoryId, Email, ContactName, Extension, Telephone
    from ContactsXDirectory
    where DirectoryId = @DirectoryId
END;
GO