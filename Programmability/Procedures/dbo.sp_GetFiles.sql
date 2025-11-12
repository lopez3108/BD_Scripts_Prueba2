SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetFiles]
 (
	  
	  @Name varchar (50) = null

    )
AS 

BEGIN

SELECT        Files.FileId, Files.Name, Files.Description, Files.Location, Files.UploadedBy, Files.DateUploaded, Users.Name AS UploadedByName
FROM            Files INNER JOIN
                         Users ON Files.UploadedBy = Users.UserId
						 WHERE 
						 Files.Name LIKE CASE
						 WHEN @Name IS NULL THEN
						 Files.Name ELSE
						 '%' + @Name + '%'
						 END


	END

GO