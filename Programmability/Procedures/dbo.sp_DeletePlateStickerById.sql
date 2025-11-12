SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePlateStickerById](@PlateStickerId INT)
AS
     BEGIN
	 DELETE FROM PromotionalCodesStatus
         WHERE PlateStickerId = @PlateStickerId;
         DELETE FROM PlateStickers
         WHERE PlateStickerId = @PlateStickerId;
     END;
GO