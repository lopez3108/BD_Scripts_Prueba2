SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAgenda] 
  @AgendaId INT
AS 
  DELETE NotesXAgenda WHERE AgendaId = @AgendaId
  DELETE ReminderAgenda WHERE AgendaId = @AgendaId
  DELETE Agendas   WHERE AgendaId = @AgendaId
GO