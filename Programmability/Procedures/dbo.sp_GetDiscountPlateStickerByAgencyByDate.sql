SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetDiscountPlateStickerByAgencyByDate]
(@CreatedBy    INT,
 @AgencyId     INT,
 @CreationDate DATE
)
AS
     BEGIN
         SELECT d.DiscountPlateStickerId,
                0 as Quantity,
                d.Usd,
                d.CreationDate,
                d.CreatedBy,
                d.AgencyId,
                d.Discount
         FROM DiscountPlateStickers d
         WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND d.AgencyId = @AgencyId;
     END;

GO