SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveComisionVentraSetting]
(@ComisionVentraSettingId INT            = NULL,
 @Reload                  DECIMAL(18, 2)
)
AS
     BEGIN
         IF(@ComisionVentraSettingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].CommisionVentraSetting  
                 (Reload
                 )
                 VALUES
                 (@Reload
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].CommisionVentraSetting
                   SET
                       Reload = @Reload
                 WHERE ComisionVentraSettingId = @ComisionVentraSettingId;
         END;
     END;
GO