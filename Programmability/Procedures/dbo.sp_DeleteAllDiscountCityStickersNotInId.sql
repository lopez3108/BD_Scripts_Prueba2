SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllDiscountCityStickersNotInId]
(@DiscountCityStickerList VARCHAR(1000),
 @Date                     DATE,
 @AgencyId                 INT,
 @UserId                   INT
)
AS
     BEGIN
         DELETE FROM DiscountCityStickers
         WHERE DiscountCityStickerId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@DiscountCityStickerList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
         AND AgencyId = @AgencyId
         AND CreatedBy = @UserId;
     END;
GO