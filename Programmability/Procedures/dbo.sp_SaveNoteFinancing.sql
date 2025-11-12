SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNoteFinancing]
(@FinancingNoteId INT          = NULL,
 @FinancingId     INT,
 @Note            VARCHAR(300),
 @CreatedBy       INT,
 @CreationDate    DATETIME
)
AS
     BEGIN
         IF(@FinancingNoteId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[FinancingNotes]
                 (Note,
                  CreatedBy,
                  CreationDate,
			   FinancingId
                 )
                 VALUES
                 (@Note,
                  @CreatedBy,
                  @CreationDate,
			   @FinancingId
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[FinancingNotes]
                   SET
                       Note = @Note
                 WHERE FinancingNoteId = @FinancingNoteId;
         END;
     END;
GO