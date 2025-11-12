SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-04-15 JF/6421: Corregir registro de last updated by y on

CREATE PROCEDURE [dbo].[sp_SaveNoteXTicket]
(@NoteXTicketId INT = NULL,
@TicketId INT,
@Note VARCHAR(400),
@CreatedBy INT,
@CreationDate DATETIME)
AS
BEGIN
  IF (@NoteXTicketId IS NULL)
  BEGIN
    INSERT INTO [dbo].NotesXTicket (CreatedBy, Note, CreationDate, TicketId)
                            VALUES (@CreatedBy, @Note, @CreationDate, @TicketId);
      --actualizar la tabla Ticket
  UPDATE [dbo].Tickets
    SET  LastUpdatedBy = @CreatedBy, LastUpdatedOn = @CreationDate
    WHERE TicketId = @TicketId;

  END;
  ELSE
  BEGIN
    UPDATE [dbo].NotesXTicket
    SET CreatedBy = @CreatedBy
       ,Note = @Note
       ,CreationDate = @CreationDate
       ,TicketId = @TicketId
    WHERE NoteXTicketId = @NoteXTicketId;

  END;
END;
GO