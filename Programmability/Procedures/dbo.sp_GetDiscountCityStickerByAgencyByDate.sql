SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetDiscountCityStickerByAgencyByDate]
(@CreatedBy    INT,
 @AgencyId     INT,
 @CreationDate DATE
)
AS
     BEGIN
         SELECT d.DiscountCityStickerId,
                0 as Quantity,
                d.Usd,
                d.CreationDate,
                d.CreatedBy,
                d.AgencyId
         FROM DiscountCityStickers d
         WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND d.AgencyId = @AgencyId;
     END;

GO