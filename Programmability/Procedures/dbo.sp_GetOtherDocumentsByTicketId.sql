SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 24/07/2025  Description: task 6684  Permitir adjuntar varios documetos a los tickets

CREATE PROCEDURE [dbo].[sp_GetOtherDocumentsByTicketId] @TicketId INT = NULL


AS
BEGIN
  SELECT
    tod.DocumentId
   ,tod.FileNameOthers
   ,tod.FileNameOthers FileNameOthersSaved

  FROM TicketOtherDocuments tod

  WHERE @TicketId = TicketId


END



GO