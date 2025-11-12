SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetLastNews](@UserId INT = NULL)
AS
     BEGIN
	--Las noticias que se muestran en el modal de mis news, se muestran solamente las últimas 30 por petición de Jorge el 14-7-2023
         SELECT TOP 200 *,
                       uc.name AS UserName,
		--(SELECT COUNT(*)FROM NewsXUsers WHERE NewsId = N.NewsId) as usersRead,
                       --123 AS usersRead,
         (
             SELECT COUNT(*)
             FROM Users
         ) AS totalUsers
         FROM dbo.News n
              LEFT JOIN dbo.NewsXUsers nu ON n.NewsId = nu.NewsId
                                             AND (nu.UserId = @UserId)
              LEFT JOIN Users u ON nu.userid = u.userid
              INNER JOIN Users uc ON uc.UserId = n.CreatedBy
			 --where  NU.UserId = 144  or nu.NewsXCashierId IS NULL
         ORDER BY NewsxCashierId ASC,
                  n.creationDate DESC;
     END;
GO