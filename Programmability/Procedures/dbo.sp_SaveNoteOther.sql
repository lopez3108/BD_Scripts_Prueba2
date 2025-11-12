SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveNoteOther]
(@CreationDate DATETIME, 
 @Usd          DECIMAL, 
 @CreatedBy    INT, 
 @ValidatedBy  INT = NULL, 
 @Note         VARCHAR(400), 
 @AgencyId     INT,
 @OtherDetailId    INT
)
AS
    BEGIN
        INSERT INTO [dbo].OthersNotes
        (CreationDate, 
         Usd, 
         CreatedBy, 
         ValidatedBy, 
         Note, 
         AgencyId,
		 OtherDetailId
        )
        VALUES
        (@CreationDate, 
         @Usd, 
         @CreatedBy, 
         @ValidatedBy, 
         @Note, 
         @AgencyId,
		 @OtherDetailId
        );
    END;

GO