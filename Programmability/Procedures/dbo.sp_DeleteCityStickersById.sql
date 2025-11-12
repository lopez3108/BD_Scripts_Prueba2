SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCityStickersById](@CityStickerId INT)
AS
     BEGIN
         DELETE FROM PromotionalCodesStatus
         WHERE CityStickerId = @CityStickerId;
         DELETE FROM CityStickers
         WHERE CityStickerId = @CityStickerId;
     END;
GO