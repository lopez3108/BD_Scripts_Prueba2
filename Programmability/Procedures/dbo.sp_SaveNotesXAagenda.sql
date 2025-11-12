SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotesXAagenda]
(@NoteXAgendaId INT = NULL,
@AgendaId INT,
@Note VARCHAR(400),
@CreatedBy INT,
@CreationDate DATETIME)
AS
BEGIN
  IF (@NoteXAgendaId IS NULL)
  BEGIN
    INSERT INTO [dbo].NotesXAgenda (CreatedBy, Note, CreationDate, AgendaId)
                            VALUES (@CreatedBy,@Note,@CreationDate,@AgendaId);
  END;
--  ELSE
--  BEGIN
--    UPDATE [dbo].NotesXAgenda
--    SET CreatedBy = @CreatedBy
--       ,Note = @Note
--       ,CreationDate = @CreationDate
--       ,AgendaId = @AgendaId
--    WHERE NoteXAgendaId = @NoteXAgendaId;
--
--  END;
END;
GO