SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_SaveNoteProvisional]
(@ProvisionalNotesId INT          = NULL, 
 @ProvisionalReceiptId       INT          = NULL, 
 @Note                 VARCHAR(300), 
 @CreatedBy            INT, 
 @CreationDate         DATETIME
)
AS
    BEGIN
        IF(@ProvisionalNotesId IS NULL)
            BEGIN
                INSERT INTO [dbo].[ProvisionalNote]
                (Note, 
                 CreatedBy, 
                 CreationDate, 
                 ProvisionalReceiptId
                )
                VALUES
                (@Note, 
                 @CreatedBy, 
                 @CreationDate, 
                 @ProvisionalReceiptId
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ProvisionalNote]
                  SET 
                      Note = @Note
                WHERE ProvisionalNotesId = @ProvisionalNotesId;
            END;
    END;
GO