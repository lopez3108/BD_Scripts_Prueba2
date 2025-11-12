SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- date 24/07/2025  Description: task 6684  Permitir adjuntar varios documetos a los tickets

CREATE PROCEDURE [dbo].[sp_CreateTicketOtherDocument] @DocumentId INT = NULL,
@TicketId INT = NULL,
@FileNameOthers VARCHAR(256) = NULL



AS
BEGIN
  IF (@DocumentId IS NULL)
  BEGIN
    INSERT INTO [dbo].[TicketOtherDocuments] ([TicketId], [FileNameOthers])
      VALUES (@TicketId, @FileNameOthers);
    SELECT
      @@IDENTITY;

  END
  ELSE
  BEGIN

    UPDATE [dbo].TicketOtherDocuments
    SET FileNameOthers = @FileNameOthers
     

    WHERE DocumentId = @DocumentId;
    SELECT
      @DocumentId;


  END



END;


GO