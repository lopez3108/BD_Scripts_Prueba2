SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/12-09-2024  Task 4212 Chat- Usuarios nuevos en un grupo no debe ver los mensajes anteriores 
--Last update by JT/26-07-2025  Task 6696 Permitir editar mensajes de chat, add fields Edited and edited on
--Last updateby JT/26-07-2025  Task 6714 Permitir eliminar mensajes de chat, add fields Deleted and Deleted on
--Last update by JT/31-07-2025  Task 6718 Permitir reenviar mensajes de chat, add fields Forwarded

CREATE PROCEDURE [dbo].[sp_GetAllChatMessages] @GroupId INT = NULL,
@UserId INT = NULL,
@ToUserId INT = NULL
AS
BEGIN 
  DECLARE @RegistrationDate DATETIME;

  -- Obtener la fecha de registro del usuario en el grupo
  SELECT
    @RegistrationDate = CreationDate
  FROM UsersXGroup
  WHERE UserId = @UserId
  AND GroupId = @GroupId;

  SELECT
    c.ChatMessageId
   ,c.MessageGuid
   ,c.ToGroupId
   ,c.ToUserId
   ,CASE
      WHEN c.FromUserId IS NULL THEN -999
      ELSE c.FromUserId
    END AS FromUserId
   ,c.Time
   ,c.Message
   ,c.IsFile
   ,c.ChatColor
   ,tu.UserId ToUserId
   ,fu.UserId FromUserId
   ,tu.Name ToUserName
   ,CASE
      WHEN c.FromUserId IS NULL THEN 'SYSTEM ADMIN'
      ELSE fu.Name
    END AS FromUserName
   ,
    --fu.Name FromUserName,
    cs.Name ChatStatusName
   ,CAST(cs.Code AS VARCHAR(10)) ChatStatusCode
   ,cs.ChatStatusId
   ,CAST(CASE
      WHEN r.ReadUserId = @UserId OR
        c.FromUserId = @UserId THEN 1
      ELSE 0
    END AS BIT) AS IsReadByMe
   ,cp.Message ParentMessage
   ,c.ParentId
   ,cp.MessageGuid ParentMessageGuid
   ,upf.UserId UserIdParentFrom
   ,upt.UserId UserIdParentTo
   ,upf.Name UserParentFrom
   ,upt.Name UserParentTo
   ,c.Extension
   ,c.Edited
   ,c.EditedOn
   ,c.Deleted
   ,c.DeletedOn
   ,c.Forwarded
  FROM ChatMessages c
  LEFT JOIN Users tu
    ON tu.UserId = c.ToUserId
      AND @ToUserId IS NOT NULL
  LEFT JOIN Users fu
    ON fu.UserId = c.FromUserId
  LEFT JOIN Groups g
    ON g.GroupId = c.ToGroupId
      AND @GroupId IS NOT NULL
  INNER JOIN ChatStatus cs
    ON cs.ChatStatusId = c.ChatStatusId
  LEFT JOIN ReadsByChat r
    ON c.ChatMessageId = r.ChatMessageId
      AND r.ReadUserId = @UserId
  LEFT JOIN ChatMessages cp
    ON cp.ChatMessageId = c.ParentId
  LEFT JOIN Users upf
    ON upf.UserId = cp.FromUserId
  LEFT JOIN Users upt
    ON upt.UserId = cp.ToUserId
  WHERE ((c.ToGroupId = @GroupId
  AND @GroupId IS NOT NULL)
  OR (c.FromUserId = @UserId
  AND c.ToUserId = @ToUserId)
  OR (c.FromUserId = @ToUserId
  AND c.ToUserId = @UserId)
  OR (c.ToUserId = @UserId
  AND @ToUserId = -999
  AND c.FromSystem = 1))
  AND ((c.Time >= @RegistrationDate
  AND @GroupId IS NOT NULL)
  OR @GroupId IS NULL)
  --ORDER BY c.Time ASC
  ORDER BY c.ChatMessageId
END;


GO