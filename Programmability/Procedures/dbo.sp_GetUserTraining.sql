SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUserTraining] @TrainingId INT = NULL
AS
     BEGIN
         SELECT *
         FROM
         (
             SELECT u.Name,
                    CASE
                        WHEN TA.TrainingXUserId IS NOT NULL
                        THEN CAST(1 AS BIT)
                        ELSE CAST(0 AS BIT)
                    END AS IsRead
            FROM TrainingXUsers TA
                  --INNER JOIN users u ON TA.UserId = u.UserId
                  --                      AND TA.TrainingId = @TrainingId
                  ----LEFT JOIN TrainingXUsers vu ON TA.UserId = vu.UserId
				  right join users  u on TA.UserId = u.UserId  AND TA.TrainingId = @TrainingId
					INNER JOIN Cashiers c ON C.UserId = u.UserId  
         ) Q
         ORDER BY Q.IsRead ASC,
                  q.Name ASC;
     END;


GO