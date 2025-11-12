SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveGeneralNotes]
(@GeneralNoteId        INT            = NULL, 
 @Description          VARCHAR(2000)= NULL, 
 @GeneralNotesStatusId INT            = NULL, 
 @ProviderId           INT            = NULL, 
 @ClientName           VARCHAR(150)   = NULL, 
 @ClientTelephone      VARCHAR(10)    = NULL, 
 @TransactionNumber    VARCHAR(30)    = NULL, 
 @OtherDescription     VARCHAR(80)    = NULL, 
 @CreationDate         DATETIME       = NULL, 
 @CreatedBy            INT            = NULL, 
 @AgencyId             INT            = NULL, 
 @ClosedBy             INT            = NULL, 
 @ClosedOn             DATETIME       = NULL,
 @TelIsCheck BIT = NULL,
 @FileGeneralNotes     varchar(max) = NULL,
 @IdSaved              INT OUTPUT

)
AS 

    BEGIN
        IF(@GeneralNoteId IS NULL)
            BEGIN
                INSERT INTO [dbo].[GeneralNotes]
                (Description, 
                 GeneralNotesStatusId, 
                 ProviderId, 
                 ClientName, 
                 ClientTelephone, 
                 TransactionNumber, 
                 OtherDescription, 
                 CreationDate, 
                 CreatedBy, 
                 AgencyId, 
                 ClosedBy, 
                 ClosedOn,
				 FileGeneralNotes,
				 TelIsCheck
                )
                VALUES
                (@Description, 
                 @GeneralNotesStatusId, 
                 @ProviderId, 
                 @ClientName, 
                 @ClientTelephone, 
                 @TransactionNumber, 
                 @OtherDescription, 
                 @CreationDate, 
                 @CreatedBy, 
                 @AgencyId, 
                 @ClosedBy, 
                 @ClosedOn,
				 @FileGeneralNotes,
				 @TelIsCheck
                );
				 SET @IdSaved = @@IDENTITY;
                
        END;
            ELSE
            BEGIN
                UPDATE [dbo].[GeneralNotes]
                  SET 
                      Description = @Description, 
                      GeneralNotesStatusId = @GeneralNotesStatusId, 
                      ProviderId = @ProviderId, 
                      ClientName = @ClientName, 
                      ClientTelephone = @ClientTelephone, 
                      TransactionNumber = @TransactionNumber, 
                      OtherDescription = @OtherDescription, 
                      CreationDate = @CreationDate, 
                      CreatedBy = @CreatedBy, 
                      AgencyId = @AgencyId, 
                      ClosedBy = @ClosedBy, 
                      ClosedOn = @ClosedOn,
					  FileGeneralNotes = @FileGeneralNotes,
					  TelIsCheck =@TelIsCheck
                WHERE GeneralNoteId = @GeneralNoteId;
				SET @IdSaved = @GeneralNoteId;
               
        END;
    END;
GO