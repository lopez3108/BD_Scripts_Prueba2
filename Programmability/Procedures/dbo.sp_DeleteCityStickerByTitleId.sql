SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-06-25 DJ/5923: Procedure made to clear a city sticker related to a title

CREATE PROCEDURE [dbo].[sp_DeleteCityStickerByTitleId]
(@TitleId INT
)
AS
     BEGIN

	 DELETE dbo.CityStickers WHERE TitleParentId = @TitleId
	 SELECT @TitleId
        
     END;
GO