SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDirectorysMaster] @Company VARCHAR(100),
                                                   @Telephone VARCHAR(100),
                                                   @Email VARCHAR(100),
                                                   @Contact VARCHAR(100),
                                                   @Extension VARCHAR(100),
                                                   @Department VARCHAR(100),
                                                   @Fax VARCHAR(100)
AS
BEGIN
    SELECT distinct d.*
    FROM [dbo].Directory d
             LEFT JOIN ContactsXDirectory CXD on d.DirectoryId = CXD.DirectoryId
    WHERE (d.Company LIKE '%' + @Company + '%')
       OR (d.Telephone LIKE '%' + @Telephone + '%')
       OR (d.Email LIKE '%' + @Email + '%')
       OR (CXD.ContactName LIKE '%' + @Contact + '%')
       OR (d.Extension LIKE '%' + @Extension + '%')
       OR (d.Department LIKE '%' + @Department + '%')
       OR (d.Fax LIKE '%' + @Fax + '%');
END;
GO