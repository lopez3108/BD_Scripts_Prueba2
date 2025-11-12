SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----Creted  by JT/26-07-2025  Task 6714 Permitir eliminar mensajes de chat

CREATE PROCEDURE [dbo].[sp_DeleteChatMessageById](@MessageGuid VARCHAR(200),
@DeletedOn DATETIME = NULL)
AS
     BEGIN
--         DELETE FROM ChatMessages
--         WHERE MessageGuid = @MessageGuid;

   UPDATE [dbo].ChatMessages
      SET Deleted = 1
         ,DeletedOn = @DeletedOn WHERE MessageGuid = @MessageGuid
     END;

GO