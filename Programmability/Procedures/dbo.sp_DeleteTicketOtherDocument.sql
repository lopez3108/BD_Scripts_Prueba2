SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 27/07/2025  Description: task 6684  Permitir adjuntar varios documetos a los tickets

CREATE PROCEDURE [dbo].[sp_DeleteTicketOtherDocument] @DocumentId INT = NULL
AS

BEGIN

  DELETE TicketOtherDocuments
  WHERE DocumentId = @DocumentId

END



GO