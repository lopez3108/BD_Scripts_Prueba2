SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveComisionPhoneCardsSetting]
(@ComisionPhoneCardsSettingId INT            = NULL,
 @Percentage                  DECIMAL(18, 2)
)
AS
     BEGIN
         IF(@ComisionPhoneCardsSettingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].CommisinPhoneCardsSetting(Percentage)
             VALUES(@Percentage);
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].CommisinPhoneCardsSetting
                   SET
                       Percentage = @Percentage
                 WHERE ComisionPhoneCardsSettingId = @ComisionPhoneCardsSettingId;
         END;
     END;
GO