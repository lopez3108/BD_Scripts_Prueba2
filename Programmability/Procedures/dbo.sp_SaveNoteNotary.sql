SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNoteNotary]
(@CreationDate DATETIME, 
 @Usd          DECIMAL, 
 @CreatedBy    INT, 
 @ValidatedBy  INT          = NULL, 
 @Note         VARCHAR(400), 
 @AgencyId     INT,
  @NotaryId     INT
)
AS
    BEGIN
        INSERT INTO [dbo].NotaryNotes
        (CreationDate, 
         Usd, 
         CreatedBy, 
         ValidatedBy, 
         Note, 
         AgencyId,
		 NotaryId
        )
        VALUES
        (@CreationDate, 
         @Usd, 
         @CreatedBy, 
         @ValidatedBy, 
         @Note, 
         @AgencyId,
		 @NotaryId
        );
    END;
GO