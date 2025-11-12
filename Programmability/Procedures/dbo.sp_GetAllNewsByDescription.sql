SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNewsByDescription]
(@Description VARCHAR(400) = NULL,
 @UserId      INT          = NULL
)
AS
     BEGIN
         SELECT *,
                u.name AS UserName
         FROM dbo.News n
              LEFT JOIN dbo.NewsXUsers nu ON n.NewsId = nu.NewsId
                                             AND (nu.UserId = @UserId)
              LEFT JOIN Users u ON nu.userid = u.userid
         WHERE(n.Description LIKE '%'+@Description+'%'
               OR @Description IS NULL)
         ORDER BY NewsxCashierId ASC,
                  n.creationDate DESC;
     END;
GO