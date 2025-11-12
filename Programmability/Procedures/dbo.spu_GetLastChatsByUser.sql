SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CreationOn 22-07-2025, CreationBY JT, task 6680 Permitir reenviar mensajes

CREATE PROCEDURE [dbo].[spu_GetLastChatsByUser] @UserId INT
AS
BEGIN
  SET NOCOUNT ON;

  -- CTE de chats grupales del usuario
  WITH GroupChats
  AS
  (SELECT
      'group' AS Type
     ,GR.GroupId AS ToGroupId
     ,NULL ToUserId
     ,GR.Name AS Name
     ,MAX(C.Time) AS LastMessageDate
     ,ISNULL(SUM(CASE
        WHEN R.ReadUserId = @UserId THEN 0
        ELSE 1
      END), 0) AS numNewMsg
    FROM Groups GR
    INNER JOIN UsersXGroup UXG
      ON UXG.GroupId = GR.GroupId
      AND UXG.UserId = @UserId
    LEFT JOIN ChatMessages C
      ON C.ToGroupId = GR.GroupId
    LEFT JOIN ReadsByChat R
      ON C.ChatMessageId = R.ChatMessageId
      AND R.ReadUserId = @UserId
    GROUP BY GR.GroupId
            ,GR.Name),

  -- CTE de chats privados con usuarios y con el system admin
  PrivateChats
  AS
  (
    -- Chats con usuarios reales
    SELECT
      'user' AS Type
     ,NULL ToGroupId
     ,U.UserId AS ToUserId
     ,U.Name AS Name
     ,MAX(C.Time) AS LastMessageDate
     ,ISNULL(SUM(CASE
        WHEN R.ReadUserId = @UserId THEN 0
        ELSE 1
      END), 0) AS numNewMsg
    FROM Users U
    INNER JOIN Cashiers CA
      ON CA.UserId = U.UserId
      AND CA.IsActive = 1
    LEFT JOIN ChatMessages C
      ON ((C.ToUserId = @UserId
      AND C.FromUserId = U.UserId)
      OR (C.ToUserId = U.UserId
      AND C.FromUserId = @UserId))
      AND C.ToGroupId IS NULL
    LEFT JOIN ReadsByChat R
      ON C.ChatMessageId = R.ChatMessageId
      AND R.ReadUserId = @UserId
    WHERE U.UserId <> @UserId
    GROUP BY U.UserId
            ,U.Name

  --    UNION ALL
  --
  --    -- Chat con el SYSTEM ADMIN (UserId = -999)
  --    SELECT 
  --      'user' AS Type,
  --      -999 AS Id,
  --      'SYSTEM ADMIN' AS DisplayName,
  --      MAX(C.CreatedOn) AS LastMessageDate,
  --      ISNULL(SUM(CASE WHEN R.ReadUserId = @UserId THEN 0 ELSE 1 END), 0) AS numNewMsg
  --    FROM ChatMessages C
  --    LEFT JOIN ReadsByChat R 
  --      ON C.ChatMessageId = R.ChatMessageId AND R.ReadUserId = @UserId
  --    WHERE C.ToUserId = @UserId
  --      AND C.FromUserId IS NULL
  )

  -- Unión final y orden
  SELECT
    *
  FROM (SELECT
      *
    FROM GroupChats
    UNION ALL
    SELECT
      *
    FROM PrivateChats) AS AllChats
  ORDER BY LastMessageDate DESC;
END;

GO