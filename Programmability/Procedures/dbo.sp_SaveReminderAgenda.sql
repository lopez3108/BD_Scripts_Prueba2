SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveReminderAgenda] (@ReminderAgendaId INT = NULL,
@Monday BIT = NULL,
@Tuesday BIT = NULL,
@Wednesday BIT = NULL,
@Thursday BIT = NULL,
@Friday BIT = NULL,
@Saturday BIT = NULL,
@Sunday BIT = NULL,
@CreatedBy INT = NULL,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@AgendaId INT = NULL,
@ShowReminder BIT = NULL)

AS
BEGIN
  IF (@ReminderAgendaId IS NULL) -- register new 
  BEGIN
    INSERT INTO [dbo].ReminderAgenda (Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, FromDate, ToDate, AgendaId, ShowReminder)
      VALUES (@Monday, @Tuesday, @Wednesday, @Thursday, @Friday, @Saturday, @Sunday, @FromDate, @ToDate, @AgendaId, CAST(1 AS BIT));
  END;
  ELSE IF (@ReminderAgendaId IS NOT NULL AND @ShowReminder = 0) -- user selection do not view reminder in dashboard popup
  BEGIN
    UPDATE ReminderAgenda
    SET ShowReminder = @ShowReminder
    WHERE ReminderAgendaId = @ReminderAgendaId;
  END
  ELSE  -- user update in agenda with reminder 
  BEGIN
    UPDATE [dbo].ReminderAgenda
    SET Monday = @Monday
       ,Tuesday = @Tuesday
       ,Wednesday = @Wednesday
       ,Thursday = @Thursday
       ,Friday = @Friday
       ,Saturday = @Saturday
       ,Sunday = @Sunday
       ,FromDate = @FromDate
       ,ToDate = @ToDate
       ,ShowReminder = @ShowReminder
    WHERE ReminderAgendaId = @ReminderAgendaId;

  END;
END;
GO