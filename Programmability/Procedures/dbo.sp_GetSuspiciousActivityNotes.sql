SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSuspiciousActivityNotes]
@SuspiciousActivityId INT
AS
     SET NOCOUNT ON;
    BEGIN
        


SELECT        dbo.SuspiciousActivityNotes.SuspiciousActivityNoteId, dbo.SuspiciousActivityNotes.SuspiciousActivityId, dbo.SuspiciousActivityNotes.Note, dbo.SuspiciousActivityNotes.CreationDate, dbo.SuspiciousActivityNotes.CreatedBy as UserId, 
                         dbo.Users.Name as CreatedBy
FROM            dbo.SuspiciousActivityNotes INNER JOIN
                         dbo.Users ON dbo.SuspiciousActivityNotes.CreatedBy = dbo.Users.UserId
  WHERE dbo.SuspiciousActivityNotes.SuspiciousActivityId = @SuspiciousActivityId







    END;
GO