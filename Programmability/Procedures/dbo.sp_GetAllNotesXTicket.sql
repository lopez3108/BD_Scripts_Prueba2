SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesXTicket] @TicketId INT
AS
  SELECT
  NoteXTicketId,
    nx.Note 
   ,nx.CreationDate
   ,u.Name  CreatedByName

  FROM NotesXTicket nx
  JOIN Users u
    ON u.UserId = nx.CreatedBy
  WHERE nx.TicketId = @TicketId
  ORDER BY CreationDate ASC;
GO