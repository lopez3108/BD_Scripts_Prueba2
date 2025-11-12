SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveVentra]
(@VentraId       INT            = NULL,
 @ReloadQuantity INT,
 --@VentraQuantity INT,
 @ReloadUsd      DECIMAL(18, 2),
 --@VentraCardUsd  DECIMAL(18, 2),
 @AgencyId       INT,
 @CreatedBy      INT,
 @CreationDate   DATETIME,
 @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME
)
AS
     BEGIN
         IF(@VentraId IS NULL)
             BEGIN
                 DECLARE @commission DECIMAL(18, 2);
                 SET @commission =
                 (
                     SELECT TOP 1 Reload
                     FROM [dbo].[CommisionVentraSetting]
                 );
                 INSERT INTO [dbo].Ventra
                 (ReloadUsd,
                  --VentraCardUsd,
                  ReloadQuantity,
                  --VentraQuantity,
                  AgencyId,
                  CreatedBy,
                  CreationDate,
                  Commission,
				  LastUpdatedBy, 
                 LastUpdatedOn

                 )
                 VALUES
                 (@ReloadUsd,
                  --@VentraCardUsd,
                  @ReloadQuantity,
                  --@VentraQuantity,
                  @AgencyId,
                  @CreatedBy,
                  @CreationDate,
                  @commission,
				  @LastUpdatedBy, 
                 @LastUpdatedOn
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].Ventra
                   SET
                       ReloadUsd = @ReloadUsd,
                       --VentraCardUsd = @VentraCardUsd,
                       ReloadQuantity = @ReloadQuantity,
                       --VentraQuantity = @VentraQuantity
					    LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn
                 WHERE VentraId = @VentraId;
         END;
     END;
GO