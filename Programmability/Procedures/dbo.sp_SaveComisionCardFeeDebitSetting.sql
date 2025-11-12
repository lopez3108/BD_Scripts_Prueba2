SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveComisionCardFeeDebitSetting]
(@ComisionCardFeeDebitSettingId INT            = NULL,
 @From                  DECIMAL(18, 2),
 @To                  DECIMAL(18, 2),
 @Fee                  DECIMAL(18, 2),
 @IsDefault                BIT,
 @IsPercent                BIT
)
AS
     BEGIN
         IF(@ComisionCardFeeDebitSettingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ComisionCardFeeDebitSetting([From],[To],Fee,IsDefault,IsPercent)
             VALUES(@From,@To,@Fee,@IsDefault,@IsPercent);
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ComisionCardFeeDebitSetting
                   SET
                       [From] = @From,
					   [To] = @To,
					   Fee = @Fee,
					   IsDefault = @IsDefault,
					   IsPercent = @IsPercent
                 WHERE ComisionCardFeeDebitSettingId = @ComisionCardFeeDebitSettingId;
         END;
     END;
GO