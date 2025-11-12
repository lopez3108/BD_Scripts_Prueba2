SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveComisionReturnedCheckSetting]
(@ComisionReturnedCheckSettingId INT            = NULL,
 @Fee                            DECIMAL(18, 2)
)
AS
     BEGIN
         IF(@ComisionReturnedCheckSettingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ComisionReturnedChecksSettings
                 (Fee
                 )
                 VALUES
                 (@Fee
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ComisionReturnedChecksSettings
                   SET
                       Fee = @Fee
                 WHERE ComisionReturnedCheckSettingId = @ComisionReturnedCheckSettingId;
         END;
     END;
GO