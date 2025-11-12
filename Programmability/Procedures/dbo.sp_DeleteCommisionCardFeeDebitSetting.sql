SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCommisionCardFeeDebitSetting](@ComisionCardFeeDebitSettingId INT)
AS
     BEGIN
	 DELETE FROM ComisionCardFeeDebitSetting
         WHERE ComisionCardFeeDebitSettingId = @ComisionCardFeeDebitSettingId;
       
     END;
GO