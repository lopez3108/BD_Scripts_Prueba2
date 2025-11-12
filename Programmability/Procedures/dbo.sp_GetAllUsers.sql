SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsers] @UserId INT = NULL
AS
     BEGIN
         SELECT DISTINCT
                Users.Name,
                Cashiers.CashierId,
                Users.UserId,
                Cashiers.IsActive,
                CAST(0 AS BIT) isOnline,
                CAST(0 AS BIT) hasNewPrivateMessage,
                ISNULL(
                      (
                          SELECT SUM(CASE
                                         WHEN r.ReadUserId = @UserId
                                         THEN 0
                                         ELSE 1
                                     END) AS WhioutRead
                          FROM ChatMessages c
                               LEFT JOIN ReadsByChat r ON C.ChatMessageId = r.ChatMessageId
                                                          AND r.ReadUserId = @UserId
                          WHERE c.ToGroupId IS NULL
                                AND C.ToUserId = @UserId
                                AND c.FromUserId = Users.UserId
                                AND C.FromSystem = 0
                      ), 0) numNewMsg
         FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
			  WHERE Cashiers.IsActive = 1
         UNION ALL
         SELECT 'SYSTEM ADMIN' AS Name,
                NULL AS CashierId,
                -999 AS UserId,
                0 IsActive,
                CAST(0 AS BIT) isOnline,
                CAST(0 AS BIT) hasNewPrivateMessage,
                ISNULL(
                      (
                          SELECT SUM(CASE
                                         WHEN r.ReadUserId = @UserId
                                         THEN 0
                                         ELSE 1
                                     END) AS WhioutRead
                          FROM ChatMessages c
                               LEFT JOIN ReadsByChat r ON C.ChatMessageId = r.ChatMessageId
                                                          AND r.ReadUserId = @UserId
                          WHERE c.ToGroupId IS NULL
                                AND C.ToUserId = @UserId
                                AND c.FromUserId IS NULL
						  --AND C.FromSystem = 1
                      ), 0) numNewMsg;
     END;
GO