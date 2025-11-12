SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_saveEmailContact](@DirectoryId INT = NULL,
                                             @ContactsXDirectoryId int = null,
                                             @ContactName VARCHAR(50),
                                             @Extension VARCHAR(5) = NULL,
                                             @Telephone VARCHAR(12),
                                             @Email VARCHAR(100))
AS
BEGIN
    IF (@ContactsXDirectoryId IS NULL)
        BEGIN
            insert into ContactsXDirectory (DirectoryId, ContactName, Extension, Telephone, Email)
            VALUES (@DirectoryId, @ContactName, @Extension, @Telephone, @Email)
        END;
    else
        begin
            update ContactsXDirectory
            set ContactName = @ContactName,
                Telephone   = @Telephone,
                Email       = @Email,
                Extension   = @Extension
            where ContactsXDirectoryId = @ContactsXDirectoryId
        end
END;
GO