SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Edited On 22-07-2025, CreationBY JT, task 6680 Permitir editar mensajes
--Last update by JT/26-07-2025  Task 6696 Permitir editar mensajes de chat, add fields Edited, EditedOn in edit message
--Last update by JT/31-07-2025  Task 6718 Permitir reenviar mensajes de chat, add fields Forwarded

CREATE PROCEDURE [dbo].[sp_SaveChatMessage] (@ChatMessageId INT = NULL,
@MessageGuid VARCHAR(200) = NULL,
@ParentMessageGuid VARCHAR(200) = NULL,
@ToGroupId INT = NULL,
@ToUserId INT = NULL,
@FromUserId INT = NULL,
@UserId INT = NULL,
@Time DATETIME = NULL,
@Message VARCHAR(2000) = NULL,
@ChatStatusCode CHAR(10),
@IsFile BIT = NULL,
@Extension VARCHAR(10) = NULL,
@ChatColor VARCHAR(30) = NULL,
@FromSystem BIT = NULL,
@EditedOn DATETIME = NULL,
@Edited BIT = NULL, @Forwarded BIT = NULL,
@IsRead BIT OUTPUT)
AS
BEGIN
  DECLARE @ChatStatusId INT
         ,@NumberUsersByGroup INT
         ,@NumberReads INT
         ,@ParentId INT = NULL;
  IF (@ToGroupId IS NOT NULL
    AND @ToGroupId > 0
    OR (@ToUserId IS NOT NULL
    AND (@ToUserId > 0
    OR @ToUserId = -999)))-- -999 SIGNIFICA QUE ES UN MSG DE SYSTEM
  BEGIN
    SET @ChatMessageId = (SELECT --Se consulta el @ChatMessageId
        ChatMessageId
      FROM ChatMessages
      WHERE MessageGuid = @MessageGuid);
  END;
  IF (((@ToGroupId IS NOT NULL
    AND @ToGroupId > 0)
    OR (@ToUserId IS NOT NULL
    AND (@ToUserId > 0
    OR @ToUserId = -999)))
    AND @ChatMessageId IS NOT NULL
    AND @ChatMessageId > 0)--Se pregunta si es un mensaje de grupo o usuario privado y que sea un mensaje previamente creado para saber si se debe cambiar el estado "LEÍDO"
  BEGIN
    SET @ChatStatusId = (SELECT
        ChatStatusId
      FROM ChatStatus
      WHERE Code = 'C03');
    IF NOT EXISTS (SELECT TOP 1
          1
        FROM ReadsByChat
        WHERE ChatMessageId = @ChatMessageId
        AND ReadUserId = @UserId)
    BEGIN
      --Ingresar el read en la tabla 
      INSERT INTO [dbo].ReadsByChat (ChatMessageId,
      ReadUserId)
        VALUES (@ChatMessageId, @UserId);
    END;
    IF (@ToGroupId IS NOT NULL
      AND @ToGroupId > 0)
    BEGIN
      --Se consulta si el mensaje ya fue leído por todos los usuarios del grupo 
      SET @NumberUsersByGroup = (SELECT
          COUNT(*)
        FROM UsersXGroup GX
        WHERE GX.GroupId = @ToGroupId)
      - 1; --Número de usuario x grupo , se le resta 1 que sería el usuario q envió el mensaje

      SET @NumberReads = (SELECT
          COUNT(*)
        FROM ReadsByChat
        WHERE ChatMessageId = @ChatMessageId); --Número de lectores por mensaje

      IF (@NumberReads >= @NumberUsersByGroup)
      BEGIN
        UPDATE [dbo].ChatMessages
        SET ChatStatusId = @ChatStatusId
        WHERE ChatMessageId = @ChatMessageId; --Modificamos el mensaje a estado leído por un grupo
        SET @IsRead = CAST(1 AS BIT);
      END;
      ELSE
      BEGIN
        SET @IsRead = CAST(0 AS BIT);
      END;
    END;
    ELSE
    IF (@ToUserId IS NOT NULL
      AND (@ToUserId > 0
      OR @ToUserId = -999))--Leido por un usuario
    BEGIN
      UPDATE [dbo].ChatMessages
      SET ChatStatusId = @ChatStatusId
      WHERE ChatMessageId = @ChatMessageId; --Modificamos el mensaje a estado leído por un user
      SET @IsRead = CAST(1 AS BIT);
    END;
  END;
  ELSE--Mensaje privado 
  IF (@ChatMessageId IS NULL
    OR @ChatMessageId = 0)
  BEGIN
    IF (@Edited IS NULL --Creating new message
      OR @Edited = CAST(0 AS BIT))
    BEGIN
      --Preguntamos si tiene msg parent 
      IF (@ParentMessageGuid IS NOT NULL)
      BEGIN
        SET @ParentId = (SELECT
            ChatMessageId
          FROM ChatMessages
          WHERE MessageGuid = @ParentMessageGuid);
      END;
      SET @ChatStatusId = (SELECT
          ChatStatusId
        FROM ChatStatus
        WHERE Code = @ChatStatusCode);
      INSERT INTO [dbo].ChatMessages (MessageGuid,
      ToGroupId,
      ToUserId,
      FromUserId,
      Time,
      Message,
      ChatStatusId,
      IsFile,
      Extension,
      ChatColor,
      ParentId,
      FromSystem, Forwarded)
        VALUES (@MessageGuid, @ToGroupId, @ToUserId, @FromUserId, @Time, @Message, @ChatStatusId, @IsFile, @Extension, @ChatColor, @ParentId, @FromSystem, @Forwarded);

    END
    ELSE
    BEGIN --Editing message
      UPDATE [dbo].ChatMessages
      SET Message = @Message
         ,Edited = @Edited
         ,EditedOn = @EditedOn
      WHERE MessageGuid = @MessageGuid
    END;
    SET @IsRead = CAST(0 AS BIT)
  END;
  ELSE
  BEGIN
    SET @ChatStatusId = (SELECT
        ChatStatusId
      FROM ChatStatus
      WHERE Code = @ChatStatusCode);
    UPDATE [dbo].ChatMessages
    SET ChatStatusId = @ChatStatusId
    WHERE ChatMessageId = @ChatMessageId;
    IF (@ChatStatusCode = 'C03')
    BEGIN
      SET @IsRead = CAST(1 AS BIT);
    END
    ELSE
    BEGIN
      SET @IsRead = CAST(0 AS BIT);
    END
  END;
END;



GO