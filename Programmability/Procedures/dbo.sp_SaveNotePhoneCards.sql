SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotePhoneCards]
(@CreationDate DATETIME, 
 @Usd          DECIMAL, 
 @CreatedBy    INT, 
 @ValidatedBy  INT          = NULL, 
 @Note         VARCHAR(400), 
 @AgencyId     INT,
  @PhoneCardId     INT
)
AS
    BEGIN
        INSERT INTO [dbo].PhoneCardsNotes
        (CreationDate, 
         Usd, 
         CreatedBy, 
         ValidatedBy, 
         Note, 
         AgencyId,
		 PhoneCardId
        )
        VALUES
        (@CreationDate, 
         @Usd, 
         @CreatedBy, 
         @ValidatedBy, 
         @Note, 
         @AgencyId,
		 @PhoneCardId
        );
    END;
GO