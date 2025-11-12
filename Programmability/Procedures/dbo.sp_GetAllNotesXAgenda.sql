SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesXAgenda] @AgendaId INT
AS
  SELECT
    UPPER(nx.Note) AS note
   ,nx.CreationDate AS creationDate
   ,UPPER(u.Name) AS createdByName
   ,nx.NoteXAgendaId

  FROM NotesXAgenda nx
  JOIN Users u
    ON u.UserId = nx.CreatedBy
  WHERE nx.AgendaId = @AgendaId
GO