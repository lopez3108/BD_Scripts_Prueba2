SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_SaveNoteGeneralNotes]
(@NotesXGeneralNoteId INT          = NULL, 
 @GeneralNoteId       INT, 
 @Description         VARCHAR(300), 
 @CreatedBy           INT, 
 @AgencyId            INT, 
 @CreationDate        DATETIME
)
AS
    BEGIN
        IF(@NotesXGeneralNoteId IS NULL)
            BEGIN
                INSERT INTO [dbo].NotesXGeneralNotes
                (Description, 
                 CreatedBy, 
                 CreationDate, 
                 AgencyId, 
                 GeneralNoteId
                )
                VALUES
                (@Description, 
                 @CreatedBy, 
                 @CreationDate, 
                 @AgencyId, 
                 @GeneralNoteId
                );
        END;
            ELSE
            BEGIN
                UPDATE [dbo].NotesXGeneralNotes
                  SET 
                      Description = @Description
                WHERE NotesXGeneralNoteId = @NotesXGeneralNoteId;
        END;
    END;
GO