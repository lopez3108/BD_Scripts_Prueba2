SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCancellationNote]
 (
 @NoteXCancellationId int

    )
AS 

BEGIN


IF(EXISTS(SELECT NoteXCancellationId FROM Cancellations WHERE NoteXCancellationId = @NoteXCancellationId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE NotesxCancellations WHERE NoteXCancellationId = @NoteXCancellationId

SELECT @NoteXCancellationId

END

END

GO