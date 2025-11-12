SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReminderAgendaAll] (@UserId INT,
@Date DATE)
AS
BEGIN
	DECLARE @sqlCommand VARCHAR(1000)
	DECLARE @columna VARCHAR(75)
	SET @columna = DATENAME(WEEKDAY, GETDATE())
	SET @sqlCommand =
	'SELECT a.AgendaId, a.Description, ra.ReminderAgendaId FROM ReminderAgenda ra JOIN Agendas a ON ra.AgendaId = a.AgendaId 
   JOIN AgendaStatus [as] ON a.AgendaStatusId = [as].AgendaStatusId 
   WHERE  ra.ShowReminder = CAST(1 AS BIT)  AND (([as].Code = ' + CAST('''C01''' AS NVARCHAR) + 'AND  a.CreatedBy = ' + CAST(@UserId AS NVARCHAR) + ')OR ([as].Code = ' + CAST('''C03''' AS NVARCHAR) + 'AND  a.DelegateTo = ' + CAST(@UserId AS NVARCHAR) + '))
   AND( ' + @columna + ' = CAST(1 AS BIT) OR ( CONVERT(DATETIME, ra.FromDate, 101) <= CONVERT(DATETIME, ''' + CAST(@Date AS NVARCHAR) + ''', 101) AND 
   CONVERT(DATETIME, ra.ToDate, 101) >= CONVERT(DATETIME, ''' + CAST(@Date AS NVARCHAR) + ''', 101)) )'
	EXEC (@sqlCommand)
	SELECT
		@sqlCommand
END
GO