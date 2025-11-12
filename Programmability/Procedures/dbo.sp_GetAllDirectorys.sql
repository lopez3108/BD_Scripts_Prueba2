SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDirectorys] @Company   VARCHAR(100) = NULL, 
                                            @Telephone VARCHAR(50)  = NULL, 
                                            @Email     VARCHAR(100) = NULL, 
                                            @Contact   VARCHAR(70)  = NULL
AS
    BEGIN
        SELECT *
        FROM [dbo].Directory d
        WHERE(d.Company LIKE '%'+@Company+'%'
              OR @Company IS NULL)
             AND (d.Telephone lIKE '%'+@Telephone+'%' 
                  OR @Telephone IS NULL)
             AND (d.Email lIKE '%'+@Email+'%' 
                  OR @Email IS NULL)
    END;
GO