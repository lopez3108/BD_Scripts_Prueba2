SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_SaveNoteXOrderDetails]
(@NoteXOrderSupplyId INT          = NULL, 
 @OrderOfficeSupplieId     INT, 
 @Note          VARCHAR(400), 
 @CreatedBy     INT, 
 @CreationDate  DATETIME
)
AS
    BEGIN
        IF(@NoteXOrderSupplyId IS NULL)
            BEGIN
                INSERT INTO [dbo].NotesXOrderOfficeSupply
                (CreatedBy, 
                 Note, 
                 CreationDate, 
                 OrderOfficeSupplieId
                )
                VALUES
                (@CreatedBy, 
                 @Note, 
                 @CreationDate, 
                 @OrderOfficeSupplieId
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].NotesXOrderOfficeSupply
                  SET 
                      CreatedBy = @CreatedBy, 
                      Note = @Note, 
                      CreationDate = @CreationDate, 
                      OrderOfficeSupplieId = @OrderOfficeSupplieId
                WHERE NoteXOrderSupplyId = @NoteXOrderSupplyId;
            END;
    END;
GO