SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_SaveNoteXInstruction]
(@NoteXInstructionId INT          = NULL, 
 @InstructionChangeId     INT, 
 @Note          VARCHAR(400), 
 @CreatedBy     INT, 
 @CreationDate  DATETIME
)
AS
    BEGIN
        IF(@NoteXInstructionId IS NULL)
            BEGIN
                INSERT INTO [dbo].NotesXInstructionChange
                (CreatedBy, 
                 Note, 
                 CreationDate, 
                 InstructionChangeId
                )
                VALUES
                (@CreatedBy, 
                 @Note, 
                 @CreationDate, 
                 @InstructionChangeId
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].NotesXInstructionChange
                  SET 
                      CreatedBy = @CreatedBy, 
                      Note = @Note, 
                      CreationDate = @CreationDate, 
                      InstructionChangeId = @InstructionChangeId
                WHERE NoteXInstructionId = @NoteXInstructionId;
            END;
    END;
GO