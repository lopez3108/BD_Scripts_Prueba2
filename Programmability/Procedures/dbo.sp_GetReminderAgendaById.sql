SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetReminderAgendaById] @AgendaId INT
AS
  SELECT * from ReminderAgenda

  WHERE AgendaId = @AgendaId
GO