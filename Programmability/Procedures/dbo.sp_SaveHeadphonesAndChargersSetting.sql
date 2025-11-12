SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveHeadphonesAndChargersSetting]
(@ComisionHeadphonesAndChargersSettingId INT            = NULL,
 @Headphones                             DECIMAL(18, 2),
 @Chargers                             DECIMAL(18, 2)
)
AS
     BEGIN
         IF(@ComisionHeadphonesAndChargersSettingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ComissionHeadphonesAndChargersSettings
                 (Headphones,
                  Chargers
                 )
                 VALUES
                 (@Headphones,
                  @Chargers
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ComissionHeadphonesAndChargersSettings
                   SET
                       Headphones = @Headphones,
                       Chargers = @Chargers
                 WHERE ComisionHeadphonesAndChargersSettingId = @ComisionHeadphonesAndChargersSettingId;
         END;
     END;
GO