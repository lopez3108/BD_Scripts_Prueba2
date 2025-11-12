SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna las notas de un cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetReturnNotesByReturnedCheckId]
@ReturnedCheckId INT
		 AS
		  
BEGIN

SELECT        dbo.ReturnNotes.ReturnNotesId, dbo.ReturnNotes.ReturnedCheckId, dbo.ReturnNotes.Note, dbo.ReturnNotes.CreationDate, dbo.ReturnNotes.CreatedBy, dbo.Users.Name as CreatedByName
FROM            dbo.ReturnNotes INNER JOIN
                         dbo.Users ON dbo.ReturnNotes.CreatedBy = dbo.Users.UserId
  WHERE [ReturnedCheckId] = @ReturnedCheckId
  ORDER BY [CreationDate] ASC

END
GO