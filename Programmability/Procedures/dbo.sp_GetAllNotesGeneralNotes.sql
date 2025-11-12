SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesGeneralNotes] @GeneralNoteId INT = NULL
AS
    BEGIN
        SELECT NotesXGeneralNoteId, 
               GeneralNoteId, 
               Description, 
               CreationDate, 
               CreatedBy, 
               Agencies.AgencyId, 
               Users.Name AS CreatedByName
        FROM [dbo].NotesXGeneralNotes
             INNER JOIN Users ON [dbo].NotesXGeneralNotes.CreatedBy = Users.UserId
             INNER JOIN Agencies ON Agencies.AgencyId = NotesXGeneralNotes.AgencyId
        WHERE GeneralNoteId = @GeneralNoteId
        ORDER BY CreationDate ASC;
    END;
GO