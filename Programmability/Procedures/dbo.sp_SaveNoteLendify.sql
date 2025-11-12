SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_SaveNoteLendify]
(@LendifyNotesId INT          = NULL, 
 @LendifyId      INT, 
 @Note           VARCHAR(300), 
 @CreatedBy      INT, 
 @CreationDate   DATETIME
)
AS
    BEGIN
        IF(@LendifyNotesId IS NULL)
            BEGIN
                INSERT INTO [dbo].lendifyNotes
                (Note, 
                 CreatedBy, 
                 CreationDate, 
                 LendifyId
                )
                VALUES
                (@Note, 
                 @CreatedBy, 
                 @CreationDate, 
                 @LendifyId
                );
        END;
            ELSE
            BEGIN
                UPDATE [dbo].lendifyNotes
                  SET 
                      Note = @Note
                WHERE LendifyNotesId = @LendifyNotesId;
        END;
    END;
GO