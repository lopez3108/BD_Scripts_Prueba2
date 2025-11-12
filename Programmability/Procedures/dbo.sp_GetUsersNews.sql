SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUsersNews] @NewsId     INT = NULL
                                             
AS
BEGIN
   
   SELECT * FROM( SELECT u.Name ,CASE WHEN vu.NewsXCashierId IS NOT NULL THEN 'true' ELSE 'false'end as IsRead  FROM  NewsXUsers vu right join users  u 
   on vu.UserId = u.UserId  AND vu.NewsId = @NewsId
   INNER JOIN Cashiers c ON C.UserId = u.UserId    ) Q ORDER BY Q.IsRead asc , q.Name asc
     END;
GO