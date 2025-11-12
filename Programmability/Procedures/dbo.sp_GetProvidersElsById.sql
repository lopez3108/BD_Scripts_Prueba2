SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProvidersElsById](@ProviderElsId int)
AS
     BEGIN
         SELECT *
         FROM ProvidersEls P LEFT JOIN PlateStickersFee2 F ON P.ProviderElsId = F.ProviderElsId
         WHERE P.ProviderElsId = @ProviderElsId;
     END;

GO