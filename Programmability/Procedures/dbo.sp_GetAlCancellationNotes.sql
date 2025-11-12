SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAlCancellationNotes]
 
AS 

BEGIN

SELECT [NoteXCancellationId]
      ,[Description]
  FROM [dbo].[NotesxCancellations]
	
	END

GO