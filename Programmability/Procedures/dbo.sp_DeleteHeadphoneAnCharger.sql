SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteHeadphoneAnCharger] @HeadphonesAndChargerId INT
AS
     BEGIN
         DELETE FROM [dbo].HeadphonesAndChargers
         WHERE HeadphonesAndChargerId = @HeadphonesAndChargerId;
         SELECT 1;
     END;
GO