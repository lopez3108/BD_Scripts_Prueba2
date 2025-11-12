SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllNews]
(@Description VARCHAR(400) = NULL,
 @FromDate    DATETIME     = NULL,
 @ToDate      DATETIME     = NULL,
 @Status      BIT          = NULL
)
AS
     BEGIN 
--IF(@Status = 1) --COMPLETE
--BEGIN 



--END

         SELECT QUERY.*
         FROM
         (
             SELECT *,			
			 FORMAT(n.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
       u.Name AS UserName,
             (
                 SELECT COUNT(*)
                 FROM NewsXUsers
                 WHERE NewsId = N.NewsId
             ) AS CountViewers,
                    CAST(
                        (
                            SELECT COUNT(*)
                            FROM NewsXUsers
                            WHERE NewsId = N.NewsId
                        ) AS VARCHAR(100))+' of '+CAST(
                                                      (
                                                          SELECT COUNT(*)
                                                          FROM Users
                                                      ) AS VARCHAR(50)) AS ViewsNews
             FROM dbo.News n
             INNER JOIN Users u ON u.UserId = n.CreatedBy
             WHERE(n.Description LIKE '%'+@Description+'%'
                   OR @Description IS NULL)
                  AND ((CAST(n.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                       AND (CAST(n.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
                       OR @ToDate IS NULL)
         ) AS QUERY
         WHERE((QUERY.CountViewers =
               (
                   SELECT COUNT(UserId) Quantity
                   FROM Users
               )
                AND @Status = 1)
               OR (
                  (
                      SELECT COUNT(*) Quantity
                      FROM NewsXUsers nu
                      WHERE nu.NewsId = QUERY.NewsId
                  ) <
                  (
                      SELECT COUNT(UserId) Quantity
                      FROM Users
                  )
                  AND @Status = 0)
               OR @Status IS NULL)
         ORDER BY QUERY.CreationDate DESC;
     END;

	
GO