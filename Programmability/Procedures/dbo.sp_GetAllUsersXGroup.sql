SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsersXGroup] @GroupId INT = NULL,
                                              @UserId  INT = NULL
AS
     BEGIN
         SELECT gx.*,
                u.Name NameUser,
                g.*,
		 ua.Name CreatedByName,
                CASE
                    WHEN GX.UserId = g.CreatedBy
                    THEN CAST(1  AS BIT)
                    ELSE CAST(0  AS BIT)
                END AS IsAdmin
         FROM UsersXGroup GX
              INNER JOIN Users u ON gx.UserId = u.UserId
              INNER JOIN Groups g ON g.GroupId = gx.Groupid
              INNER JOIN Users ua ON ua.UserId = g.CreatedBy
         WHERE GX.GroupId = @GroupId;
     END;

	
	
GO