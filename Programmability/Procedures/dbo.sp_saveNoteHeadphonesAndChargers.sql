SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_saveNoteHeadphonesAndChargers]
(@CreationDate DATETIME, 
 @Usd          DECIMAL, 
 @CreatedBy    INT, 
 @ValidatedBy  INT, 
 @Note         VARCHAR(400), 
 @AgencyId     INT,
  @HeadphonesAndChargerId     INT
)
AS
    BEGIN
        INSERT INTO [dbo].HeadphonesAndChargersNotes
        (CreationDate,
		HeadphonesAndChargerId,
         Usd, 
         CreatedBy, 
         ValidatedBy, 
         Note, 
         AgencyId
        )
        VALUES
        (@CreationDate, 
		@HeadphonesAndChargerId,
         @Usd, 
         @CreatedBy, 
         @ValidatedBy, 
         @Note, 
         @AgencyId
        );
    END;
GO